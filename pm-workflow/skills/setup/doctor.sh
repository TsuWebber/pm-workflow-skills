#!/usr/bin/env bash
#
# setup / doctor.sh —— spec repo 環境健檢（唯讀，不安裝、不改任何設定）
#
# 印出每一項的狀態，讓 agent 決定要裝什麼、要帶哪個授權。可重複跑。
#
# 輸出格式：<狀態><TAB><項目><TAB><說明>
#   OK    已裝好且已設定
#   TODO  缺、或裝了但還沒設定 → 需要處理
#   WARN  能用，但有隱憂
#
# 用法：bash doctor.sh

set -uo pipefail

GITEA_HOST="<GIT_HOST>"

ok()   { printf 'OK\t%s\t%s\n'   "$1" "$2"; }
todo() { printf 'TODO\t%s\t%s\n' "$1" "$2"; }
warn() { printf 'WARN\t%s\t%s\n' "$1" "$2"; }

# ---------- 平台 ----------
case "$(uname -s 2>/dev/null)" in
  Darwin) PLAT="mac" ;;
  Linux)  if grep -qi microsoft /proc/version 2>/dev/null; then PLAT="wsl"; else PLAT="linux"; fi ;;
  MINGW*|MSYS*|CYGWIN*) PLAT="windows-gitbash" ;;
  *) PLAT="unknown" ;;
esac
printf 'INFO\tplatform\t%s\n' "$PLAT"

# ---------- 套件管理器（agent 要用它安裝）----------
if [ "$PLAT" = "mac" ]; then
  if command -v brew >/dev/null; then ok "brew" "$(brew --version 2>/dev/null | head -1)"
  else todo "brew" "mac 缺 Homebrew，其他工具都靠它裝：https://brew.sh"; fi
elif [ "$PLAT" = "windows-gitbash" ]; then
  if command -v winget >/dev/null; then ok "winget" "可用"
  elif command -v scoop >/dev/null; then ok "scoop" "可用"
  else todo "winget/scoop" "Windows 缺套件管理器，建議先裝 winget（App Installer）或 scoop"; fi
fi

# ---------- 內網 / VPN（最常見的卡關原因，先驗）----------
if curl -sS -m 8 -o /dev/null -w '%{http_code}' "https://${GITEA_HOST}/api/v1/version" 2>/dev/null | grep -qE '^(200|401|403)$'; then
  ok "內網連線" "連得到 ${GITEA_HOST}"
else
  todo "內網連線" "連不到 ${GITEA_HOST} —— 先確認 VPN / 公司內網（其他都設好也沒用，找 MIS）"
fi

# ---------- git ----------
if command -v git >/dev/null; then
  GN=$(git config --global user.name  2>/dev/null)
  GE=$(git config --global user.email 2>/dev/null)
  if [ -n "$GN" ] && [ -n "$GE" ]; then
    ok "git" "$(git --version | awk '{print $3}')，身分 ${GN} <${GE}>"
  else
    todo "git 身分" "git 有裝但沒設 user.name / user.email（commit 會沒有作者）"
  fi
else
  todo "git" "沒裝"
fi

# ---------- Gitea 憑證（能不能免密碼 push）----------
if command -v git >/dev/null; then
  CRED=$(printf 'protocol=https\nhost=%s\n\n' "$GITEA_HOST" | git credential fill 2>/dev/null)
  if printf '%s' "$CRED" | grep -q '^password='; then
    CU=$(printf '%s\n' "$CRED" | sed -n 's/^username=//p')
    ok "Gitea 憑證" "已存在（帳號 ${CU:-?}），push / 開 PR 免再輸密碼"
  else
    todo "Gitea 憑證" "尚未儲存 —— 第一次 clone / push 輸入帳密後會自動存進 Keychain"
  fi
fi

# ---------- tea（Gitea CLI）----------
if command -v tea >/dev/null; then
  if tea logins list 2>/dev/null | grep -q "$GITEA_HOST"; then
    ok "tea" "已登入 ${GITEA_HOST}"
  else
    todo "tea 登入" "tea 有裝但還沒登入（需要 Gitea access token）"
  fi
else
  todo "tea" "沒裝（選配：沒有它 /pr 會走 API 備援，仍可開 PR）"
fi

# ---------- rclone（圖片上傳 Google Drive）----------
if command -v rclone >/dev/null; then
  if rclone listremotes 2>/dev/null | grep -qx "gdrive:"; then
    ok "rclone" "$(rclone version 2>/dev/null | head -1 | awk '{print $2}')，gdrive remote 已授權"
    if rclone config show gdrive 2>/dev/null | grep -q '^client_id *= *[^ ]'; then
      :
    else
      warn "rclone client_id" "用的是 rclone 共用 client_id，2026 年內會停用 → 見 images-to-drive skill"
    fi
  else
    todo "rclone 授權" "rclone 有裝但沒有 gdrive remote（圖片傳不了 Drive）"
  fi
else
  todo "rclone" "沒裝（/images-to-drive 需要它把 Notion 圖片搬上 Drive）"
fi

# ---------- claude（Claude Code CLI）----------
if command -v claude >/dev/null; then
  ok "claude" "$(claude --version 2>/dev/null | head -1)"
else
  warn "claude" "PATH 上沒有 claude CLI（若你正透過 Claude Desktop / VSCode 擴充使用，屬正常）"
fi

# ---------- code（VSCode CLI）----------
if command -v code >/dev/null; then
  ok "code" "VSCode CLI 可用"
else
  todo "code" "PATH 上沒有 code 指令（選配；VSCode 內按 Cmd+Shift+P → Shell Command: Install 'code' in PATH）"
fi

# ---------- 摘要 ----------
exit 0
