# 建立 Pull Request 指令（drafts 專用 · Gitea）

> 本指令**只服務 `drafts/`**(編寫中、尚未上線的規格)。目標平台是 **Gitea**
> (`<GIT_HOST>/<ORG>/spec repo`),**不是 GitLab**,不要用 `glab`。
> `specs/`、`frontend/`、`routes/`、`userflows/`、`archive/` 的變更不歸這條指令管——那些請走各自的源頭 repo 或流程。

## 目的

把 `drafts/<sprint>/` 底下的草稿變更,一鍵整理成 commit → push → 在 Gitea 開 PR(目標分支 `main`)。
PR 描述聚焦「這次動了哪些草稿、屬於哪個 sprint、變更重點」。

## 執行步驟

### 1. 飛行前檢查

- 確認在 git 儲存庫中,且遠端是 Gitea(`git remote -v` 應指向 `<GIT_HOST>`)。
- 確認當前分支**不是** `main`。若在 `main`,先開一條分支:
  建議命名 `drafts/<sprint>-<slug>`(例:`drafts/2606-coupon-stacking-v2`)。
- **範圍檢查(最重要)**:用 `git status --porcelain` 確認所有變更都落在 `drafts/` 底下。
  - 若有變更觸及 `specs/`、`frontend/`、`routes/`、`userflows/`、`archive/` → **停下來問使用者**,
    不要擅自把這些一起 commit(它們多半是別的 repo 的產物,不該在此手改)。
  - `CLAUDE.md`、`index.md`、`drafts/README.md` 這類倉庫自身文件若一併變更,列出來讓使用者確認是否要納入。

### 2. 收集變更資訊

- `git status` 看檔案狀態。
- `git diff` 與 `git diff --cached` 看變更內容。
- `git log main..HEAD --oneline` 看這條分支的提交歷史。
- **讀每個異動草稿的 frontmatter**(`title`、`sprint`)——PR 描述要用。

### 3. 自動提交（如需要）

- 若有未提交變更,`git add` **只加 `drafts/`(及步驟 1 使用者確認要納入的檔)**,不要無腦 `git add -A`。
- 依變更產生繁體中文 commit 訊息,格式:`draft(<sprint>): <做了什麼>`
  (例:`draft(2606): 新增 coupon-stacking-v2 疊券規則草稿`)。

### 4. 推送到遠端

- 取得當前分支名,`git push -u origin <branch-name>`。
- 記下 push 輸出中 Gitea 回傳的「Create pull request」URL(通常是
  `.../compare/main...<branch>`),後面 fallback 會用到。

### 5. 建立 / 更新 Pull Request

依環境可用工具擇一(由上而下優先):

1. **`tea` CLI(Gitea 官方,若已安裝)**
   - 查既有 PR:`tea pr list --repo <ORG>/spec repo --state open`
   - 開新 PR:`tea pr create --repo <ORG>/spec repo --base main --head <branch> --title "<標題>" --description "<內文>"`
2. **Gitea REST API + `GITEA_TOKEN`(無 `tea`,但環境有 token 時)**:
   ```bash
   curl -s -X POST \
     -H "Authorization: token $GITEA_TOKEN" \
     -H "Content-Type: application/json" \
     https://<GIT_HOST>/api/v1/repos/<ORG>/<SPEC_REPO>/pulls \
     -d '{"base":"main","head":"<branch>","title":"<標題>","body":"<內文>"}'
   ```
3. **Gitea REST API + git 憑證(無 token 時的預設路徑)** — 若 `git push` 不用輸密碼,代表憑證已存在
   git credential store（macOS 為 Keychain）,直接取出同一組憑證打 API,**不必裝 `tea`、不必設 token**:
   ```bash
   CRED=$(printf 'protocol=https\nhost=<GIT_HOST>\n\n' | git credential fill 2>/dev/null)
   U=$(printf '%s\n' "$CRED" | sed -n 's/^username=//p')
   P=$(printf '%s\n' "$CRED" | sed -n 's/^password=//p')
   # 先確認憑證對 API 有效(HTTP 200 才往下),再用 -u "$U:$P" 打 POST /pulls 建 PR
   ```
   - **安全**:用 `git credential fill` 取值放進變數、直接餵給 `curl -u`,**過程中絕不 echo / 印出密碼**。
   - 用 `jq -n --arg ... --rawfile body <file>` 組 JSON payload,避免中文內文的跳脫問題。
4. **以上都不行 → 輸出 compare URL 讓使用者手動開**:
   `https://<GIT_HOST>/<ORG>/spec repo/compare/main...<branch>`
   並附上下方範本產生好的標題與內文,讓使用者貼上即可。

> **建 / 更新前先查重**:任一 API 路徑(2 或 3)POST 前,先 GET `.../pulls?state=open&head=<branch>`
> 確認是否已有開啟中的 PR;有就改用 PATCH `.../pulls/<number>` 更新描述,沒有才 POST 新建。

- PR 標題格式:`[drafts/<sprint>] <草稿主題>`(例:`[drafts/2606] 疊券規則 v2`)。

## PR 內文範本

```markdown
### 📝 這次動了什麼

[1-2 句:新增 / 修改了哪個草稿、為什麼。]

### 📄 影響的草稿

| 草稿 | sprint |
|---|---|
| `drafts/2606/coupon-stacking-v2.md` | 2606 |

### 🔧 變更重點

- [新增] ...
- [修改] ...
- [刪除] ...

### ❓ 待釐清（如有）

- Q1: ...(未定案 / 待 PM 拍板 / 待後端確認)

### 🚦 尚未上線提醒

本 PR 內容位於 `drafts/`,屬**編寫中規格**,合併後**仍未上線**。
```

## 撰寫規則

- 繁體中文為主,技術名詞(API path、欄位名、狀態 enum)保留英文。
- 變更逐條標 `[新增]` / `[修改]` / `[刪除]`,對齊 `drafts/README.md` 的慣例。
- 內文只描述**規格差異**,不要塞 migration、部署命令、程式碼實作——那些不屬於 spec repo。
- 忠實呈現:草稿還有 `TBD` / 未定案就寫進「待釐清」,不要假裝已定案。

## 重要提醒

- 本指令**只 commit `drafts/`**(及使用者明確確認要納入的倉庫文件),不會動到四個現況區。
- 目標分支固定 `main`(此 repo 沒有 `develop`)。
- 平台是 **Gitea**,terminology 用 **Pull Request(PR)**,不要用 GitLab 的 `glab` 或 MR 流程。
- 若要指派 reviewer,建 PR 後在 Gitea 網頁手動設定。
