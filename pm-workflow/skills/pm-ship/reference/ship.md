# Ship - 把 drafts 草稿一鍵出貨（Gitea）

> **IMPORTANT**:本指令只服務 `drafts/`。目標平台 **Gitea**,不要用 `glab` / GitLab MR 流程。
> 變更票不在此指令直接寫,一律委派 `pm-ticket spec`(預設不建,加 `--ticket` 才建)。
> 若變更觸及 `specs/`、`frontend/`、`routes/`、`userflows/`、`archive/` → **停下來問使用者**,不要一起送出。

從當前 `drafts/` 變更出發,自動完成:分析變更 →(在 `main` 上就先開分支)→ 智慧分組 commit → push → 在 Gitea 建 PR(目標 `main`)→(選用)建 FE/BE 變更票。

## 使用方式

```
pm-ship [description] [--no-pr] [--ticket [parent_key]]
```

| 參數 | 必填 | 說明 | 預設 |
|---|---|---|---|
| `[description]` | 否 | 變更描述;未提供則從 `git diff` 自動分析 | 自動分析 |
| `[--no-pr]` | 否 | 只做 commit + push,跳過建 PR | 預設含建 PR |
| `[--ticket [parent_key]]` | 否 | 依草稿內容建 FE/BE 變更票(委派 `pm-ticket spec`);可帶 parent key | 預設不建票 |

---

## 執行流程

### Phase 1: 前置檢查

1. 確認在 git 儲存庫,且遠端是 Gitea(`git remote -v` 指向 `<GIT_HOST>`)。
2. `git status --porcelain` 確認有變更;working directory clean 且未提供 description → 停止。
3. **範圍檢查**:所有變更須落在 `drafts/`。若碰到現況區(specs / userflows)或 `archive/` → 停下詢問,不要擅自納入。
   `CLAUDE.md`、`index.md`、`drafts/README.md`、`.claude/` 這類倉庫文件若一併變更,列出來讓使用者確認是否納入。

### Phase 1.5: 確認既有 PR 是否已合併（每次 ship 必做）

> **動機**:PR 可能在你上次 push 之後已被合併。若繼續 push 到「已合併的分支」,新 commit **不會進 `main`**(那條分支的 PR 已關閉,要另開新 PR 才進得去)——這正是漏 commit 的成因。所以**每次 ship 前先查一次**。

1. 當前分支 = `main` → 還沒有對應 PR,跳過本階段,進 Phase 2。
2. 否則查當前分支的 PR 狀態(沿用 [`pm-ship（開 PR 步驟）`](pr.md) 的 Gitea 憑證 / API 路徑):
   `GET .../repos/<ORG>/<SPEC_REPO>/pulls?state=all`,在結果中找 `head.ref == <當前分支>` 的最新一筆,看 `merged` 欄位。
   > `head` 查詢參數在此 Gitea 常被忽略,**用 `state=all` 撈回來自己比對 `head.ref`**,不要只信 filter。
3. 依狀態決定:
   - **已合併**(`merged: true`)→ **停下告知使用者**「這條分支的 PR #N 已合併,不該再 push 上去」。建議改走:`git checkout main && git pull --ff-only` 取最新 → 從最新 `main` 另開新分支帶上目前變更(等同 Phase 3「當前是 main」路徑)→ 這批當**新 PR** 送。**未經使用者確認前不 push。**
   - **開啟中**(open)→ 正常繼續;Phase 6 會就地更新該 PR。
   - **查無 PR** → 正常繼續;Phase 6 會新建。

### Phase 2: 取得描述

- 有提供 → 直接用。
- 未提供 → 分析 `git diff` + `git diff --cached` + `git status` 推斷意圖,並讀異動草稿的 frontmatter(`title`、`sprint`)。

### Phase 3: 分支

- 當前不是 `main` → 沿用當前分支。
- 當前是 `main` → 開新分支:`git checkout -b drafts/<sprint>-<slug> main`
  (slug 取草稿主題,例:`drafts/2606-coupon-stacking-v2`)。

### Phase 4: 智慧分組 commit（依 `pm-ship（commit 步驟）`）

- **只 add `drafts/`**(及 Phase 1 使用者確認的倉庫文件),不要 `git add -A`。
- 依 sprint / 主題分組,一組一個 commit。訊息格式:
  - `draft(<sprint>): <做了什麼>`(草稿變更)
  - `docs: <做了什麼>`(README / index / CLAUDE 等倉庫文件)
- 主題行 ≤ 72 字元、不以標點結尾、**不含任何 AI 標記**(無 Co-Authored-By、無 Claude Code)。

### Phase 5: 推送

```bash
git push -u origin <branch-name>
```
記下 Gitea 回傳的 `.../compare/main...<branch>` URL 備用。

### Phase 6: 建立 Pull Request（除非 `--no-pr`）

- **PR 建立方式與內文範本沿用 [`pm-ship（開 PR 步驟）`](pr.md)**:`tea` CLI → Gitea REST API(`GITEA_TOKEN`)→ 輸出 compare URL 三段 fallback。
- 目標分支 `main`;標題 `[drafts/<sprint>] <草稿主題>`。
- 先查同分支是否已有開啟中的 PR:有就更新描述,沒有才建新的。

### Phase 7: 建立變更票（只在有 `--ticket` 時）

- 委派 [`pm-ticket spec`](ticket.md):對這次每個異動草稿,傳入 `[parent_key]`(若有)與該 draft 路徑,
  由 `pm-ticket spec` 讀草稿內容拆成 FE / BE User Story 並建票。
- 不重寫拆解邏輯——一切以 `pm-ticket spec` 為準;ship 只負責把「哪些草稿」與 parent 傳過去。
- 建好後把 ticket key 補進 PR 描述頂端(若 Phase 6 已建 PR),讓 PR ↔ ticket 互通。

### Phase 8: 輸出結果

```
✅ Ship 完成

🌿 分支: <branch-name>
📄 影響草稿: drafts/<sprint>/<...>.md
🔀 Pull Request: <pr_url 或 compare URL>
🎫 變更票(--ticket 時): [BE] <key> / [FE] <key>
```

`--no-pr` 模式省略 PR 區塊,改輸出 compare URL 讓使用者自行開。未加 `--ticket` 則省略票區塊。

---

## 撰寫規則

- 繁體中文為主,技術名詞(欄位名、狀態 enum)保留英文。
- Commit / PR 只描述**規格差異**,不塞 migration、部署命令、程式碼實作——那些不屬於 spec repo。
- 草稿還有 `TBD` / 未定案 → 誠實寫進 PR 的「待釐清」,不要假裝已定案。

## 重要提醒

- 只處理 `drafts/`;不會動四個現況區。
- 變更票交給 `pm-ticket spec`(預設不建;`--ticket` 才建 FE/BE User Story),ship 不自行拼 JIRA 邏輯。
- 平台 Gitea,terminology 用 **Pull Request**;目標分支固定 `main`(此 repo 沒有 `develop`)。
- 要指派 reviewer,建 PR 後在 Gitea 網頁手動設定。