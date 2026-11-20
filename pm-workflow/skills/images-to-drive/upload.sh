#!/usr/bin/env bash
#
# images-to-drive / upload.sh
#
# 把一份 manifest 列出的圖片（Notion signed URL 或本機檔案）上傳到指定的
# Google Drive 資料夾，並印出每張圖的可分享連結。
#
# 設計重點：圖片位元組**只在腳本內流動**，不經過 AI 的 context。
#
# 用法：
#   upload.sh --folder <Drive 資料夾連結或 ID> --manifest <manifest.tsv> [--workdir <dir>] [--public]
#
# manifest.tsv 每行兩欄，以 TAB 分隔（# 開頭為註解，空行略過）：
#   <目標檔名><TAB><來源>
# 來源可以是：
#   - http(s) URL（Notion signed URL）
#   - 本機路徑（Notion Export 出來的圖，走 Plan B 時用）
#
# stdout 每行一筆結果，TAB 分隔：
#   OK<TAB><檔名><TAB><Drive 連結>
#   FAIL<TAB><檔名><TAB><原因>
#
# 存取權限：
#   本腳本**只上傳、絕不改任何分享設定**。圖片的可見範圍完全由「目標 Drive 資料夾
#   本身的權限」決定（繼承而來）。規格圖可能含真實客戶資料 / 統編 / 印章，
#   **一律不得設成「知道連結的人都能看」**——這裡刻意不提供任何產生公開連結的選項。
#
# 環境變數：
#   SPEC_REPO_RCLONE_REMOTE  rclone remote 名稱，預設 gdrive

set -uo pipefail

REMOTE="${SPEC_REPO_RCLONE_REMOTE:-gdrive}"
FOLDER=""
MANIFEST=""
WORKDIR=""

die() { printf 'ERROR: %s\n' "$1" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --folder)   FOLDER="${2:-}"; shift 2 ;;
    --manifest) MANIFEST="${2:-}"; shift 2 ;;
    --workdir)  WORKDIR="${2:-}"; shift 2 ;;
    --public|--share|--anyone)
      die "不支援 --public：規格圖可能含真實客戶資料，禁止設成「知道連結的人都能看」。可見範圍請由 Drive 資料夾權限控管。" ;;
    -h|--help)  sed -n '2,34p' "$0"; exit 0 ;;
    *) die "未知參數：$1" ;;
  esac
done

[ -n "$FOLDER" ]   || die "缺 --folder"
[ -n "$MANIFEST" ] || die "缺 --manifest"
[ -f "$MANIFEST" ] || die "manifest 不存在：$MANIFEST"

command -v rclone >/dev/null || die "找不到 rclone。mac: brew install rclone / windows: winget install Rclone.Rclone"
command -v curl   >/dev/null || die "找不到 curl"

rclone listremotes | grep -qx "${REMOTE}:" \
  || die "rclone 沒有名為 '${REMOTE}' 的 remote。先跑 rclone config 接上 Google Drive，或設 SPEC_REPO_RCLONE_REMOTE。"

# Drive 資料夾連結 → folder ID
case "$FOLDER" in
  *drive.google.com*folders/*) FOLDER_ID=$(printf '%s' "$FOLDER" | sed -E 's#.*/folders/([^/?#]+).*#\1#') ;;
  *drive.google.com*)          die "看起來是 Drive 連結但不是資料夾連結（需要 .../drive/folders/<ID>）：$FOLDER" ;;
  *)                           FOLDER_ID="$FOLDER" ;;
esac
[ -n "$FOLDER_ID" ] || die "解析不出 Drive folder ID：$FOLDER"

RC="${REMOTE},root_folder_id=${FOLDER_ID}:"

rclone lsf --max-depth 1 "$RC" >/dev/null 2>&1 \
  || die "無法存取該 Drive 資料夾（ID: ${FOLDER_ID}）。確認連結正確、且 rclone 授權的帳號有權限。"

if [ -z "$WORKDIR" ]; then
  WORKDIR=$(mktemp -d 2>/dev/null || mktemp -d -t images-to-drive)
  CLEANUP=1
else
  mkdir -p "$WORKDIR" || die "無法建立 workdir：$WORKDIR"
  CLEANUP=0
fi

ok=0; fail=0

while IFS=$'\t' read -r name src _rest || [ -n "${name:-}" ]; do
  case "${name:-}" in ''|\#*) continue ;; esac
  [ -n "${src:-}" ] || { printf 'FAIL\t%s\t%s\n' "$name" "manifest 這行沒有來源欄"; fail=$((fail+1)); continue; }

  local_file="$WORKDIR/$name"

  # 1) 取得檔案：遠端就下載，本機就複製
  case "$src" in
    http://*|https://*)
      if ! curl -fsSL --max-time 180 -o "$local_file" "$src" 2>/dev/null; then
        printf 'FAIL\t%s\t%s\n' "$name" "下載失敗（signed URL 可能已過期，重抓一次 Notion 頁面）"
        fail=$((fail+1)); continue
      fi
      ;;
    file://*)
      p="${src#file://}"
      cp "$p" "$local_file" 2>/dev/null || { printf 'FAIL\t%s\t%s\n' "$name" "本機檔案讀取失敗：$p"; fail=$((fail+1)); continue; }
      ;;
    *)
      cp "$src" "$local_file" 2>/dev/null || { printf 'FAIL\t%s\t%s\n' "$name" "本機檔案讀取失敗：$src"; fail=$((fail+1)); continue; }
      ;;
  esac

  # 2) 健檢：空檔 or 拿到 HTML 錯誤頁（Notion 過期會回 XML/HTML）
  if [ ! -s "$local_file" ]; then
    printf 'FAIL\t%s\t%s\n' "$name" "下載到空檔"; fail=$((fail+1)); continue
  fi
  head_bytes=$(head -c 1 "$local_file" 2>/dev/null)
  if [ "$head_bytes" = "<" ]; then
    printf 'FAIL\t%s\t%s\n' "$name" "拿到的是 HTML/XML 錯誤頁不是圖（URL 多半已過期）"
    fail=$((fail+1)); continue
  fi

  # 3) 上傳
  if ! rclone copyto "$local_file" "${RC}${name}" 2>/dev/null; then
    printf 'FAIL\t%s\t%s\n' "$name" "rclone 上傳失敗"; fail=$((fail+1)); continue
  fi

  # 4) 取連結
  #    只查檔案 ID 組出標準 Drive 連結——不呼叫 rclone link（那會把檔案改成公開分享）。
  #    這個連結只有「本來就有該資料夾權限的人」點得開，正是我們要的。
  link=""
  # lsf --format "pi" → "<path><sep><id>"；用 TAB 當分隔避免檔名裡的符號干擾
  id=$(rclone lsf --files-only --format "pi" --separator $'\t' "$RC" 2>/dev/null \
       | awk -F'\t' -v n="$name" '$1 == n { print $2; exit }')
  [ -n "$id" ] && link="https://drive.google.com/file/d/${id}/view"

  if [ -z "$link" ]; then
    printf 'FAIL\t%s\t%s\n' "$name" "已上傳但取不到連結，請到 Drive 手動複製"
    fail=$((fail+1)); continue
  fi

  printf 'OK\t%s\t%s\n' "$name" "$link"
  ok=$((ok+1))
done < "$MANIFEST"

[ "$CLEANUP" -eq 1 ] && rm -rf "$WORKDIR"

printf '\n完成：成功 %d 張、失敗 %d 張（資料夾 ID: %s）\n' "$ok" "$fail" "$FOLDER_ID" >&2
[ "$fail" -eq 0 ] || exit 2
exit 0
