---
description: 把本地 spec repo 安全更新到 Gitea 最新版本(拉別人最新的規格),進行中的草稿不會弄丟
---

# Sync — 更新到最新版本（drafts 友善 · Gitea）

> 這是 [`/ship`](ship.md) 的**反方向**:ship 是把你的草稿**送出去**,sync 是把大家最新的規格**拉進來**。
> 目標平台 **Gitea**(`<GIT_HOST>/<ORG>/<SPEC_REPO>`),**不是 GitLab**,不要用 `glab`。
> 這條指令**只拉、不推**:不會 push、不會開 PR、不會改遠端。純粹讓你的本地 repo 追上最新版。

## 目的

給 PM(不熟 git 也能用)一鍵把本地 spec repo 更新到最新:
- 把別的 repo 自動同步進來的**現況**（`specs/` `frontend/` `routes/` `userflows/`）更新到最新;
- 把其他人在 `drafts/`、`archive/` 的最新規格拉下來;
- **過程中你自己還沒 commit 的草稿不會不見**(自動暫存、事後還原);
- 最後用白話講「這次更新多了什麼」。

## 使用方式

```
/sync
```

不需參數。若你人在自己的草稿分支上,指令跑到一半會問你「要不要順便把最新 main 併進你的分支」。

---

## 執行流程

### Phase 1: 前置檢查與抓取

1. 確認在 git 儲存庫,且遠端是 Gitea(`git remote -v` 指向 `<GIT_HOST>`)。
2. `git fetch --prune origin` 抓取遠端最新狀態(這步只更新 git 的遠端資訊,還不會動你的檔案)。
3. 記錄目前 `main` 的位置備用(算「更新了什麼」用):
   `BEFORE=$(git rev-parse main 2>/dev/null || echo "")`。
4. 判斷現況:
   - 目前在哪個分支(`git branch --show-current`);
   - 有沒有還沒 commit 的變更(`git status --porcelain`);
   - `main` 落後遠端幾個 commit(`git rev-list --count main..origin/main`,`main` 不存在時視為需要建立本地追蹤分支)。
5. 若**本地 main 已經是最新**且沒有進行中的工作 → 直接回報「已是最新版」,結束。

### Phase 2: 保護進行中的工作（WIP）

- **有未 commit 的變更**時,先判斷這些變更落在哪:
  - 若都在 `drafts/`(或使用者手寫區)且看起來是「一段完整的草稿進度」→ **建議先用 [`/ship --no-pr`](ship.md) 存成 commit** 再更新,較安全;徵得同意後委派。
  - 使用者不想先 commit,或變更零散 → **自動暫存**:`git stash push -u -m "sync-autostash"`,並記住「稍後要還原」。
- **沒有未 commit 的變更** → 跳過本階段。
- ⚠️ 絕不用 `git reset --hard` / `git checkout -- .` 這類會直接丟棄使用者變更的指令。

### Phase 3: 更新本地 main

- 切到 main 並**只做快轉合併**(fast-forward),不會產生合併 commit、也不會改寫歷史:
  ```bash
  git checkout main
  git merge --ff-only origin/main
  ```
- 若 `--ff-only` 失敗(代表本地 main 有跑掉的 commit / 與遠端分岔)→ **停下來回報**,別 force、別 rebase 硬幹;
  請使用者確認(通常 PM 的 main 不該有本地 commit,分岔多半是誤操作)。
- 本地沒有 main 追蹤分支時,`git checkout -b main origin/main` 建立。

### Phase 4: （只在你原本在草稿分支時）選擇性帶入最新 main

- 若 Phase 1 記到的原分支**不是 main**(例 `drafts/2606-product-master`),詢問使用者:
  「要不要把剛更新的最新 main 併進你的草稿分支 `<branch>`?(讓你的草稿是接在最新版上)」
- **要** → 切回該分支併入:
  ```bash
  git checkout <branch>
  git merge origin/main
  ```
  - 有衝突 → **不要自動解**。列出衝突檔案,說明兩個選項:
    (a) 請 RD / 熟 git 的人幫忙解衝突;(b) `git merge --abort` 還原、暫時不併。
  - 沒衝突 → 完成,回到該分支。
- **不要** → 只切回原分支,不動它的內容。
- 原分支就是 main → 本階段跳過(已在 Phase 3 更新完)。

### Phase 5: 還原進行中的工作

- 若 Phase 2 有 `git stash push` → 現在 `git stash pop` 還原。
  - pop 有衝突 → 回報哪些檔案衝突、暫存還留在 `git stash list`,請使用者處理,別硬吞。
- 確保最後停在**使用者原本所在的分支**,不要把人留在 main 上(除非他本來就在 main)。

### Phase 6: 回報「這次更新了什麼」

用 `BEFORE`(Phase 1 記的舊 main)對照新 main 產出白話摘要:

```bash
git log --oneline --no-merges $BEFORE..main      # 有哪些更新
git diff --stat $BEFORE..main                     # 動了哪些檔案
```

把檔案變更**依區域分組**,用產品語言講:
- `specs/` `frontend/` `routes/` `userflows/` → 「**線上現況更新**(從別的 repo 同步進來的最新規格)」
- `drafts/` → 「**其他人的草稿進度**(還沒上線)」
- `archive/` → 「**封存區更新**(有 feature 上線歸檔)」
- `index.md` / `.claude/` / 其他倉庫文件 → 「文件 / 工具更新」

`BEFORE` 為空(本來沒有本地 main)或無差異時,誠實說「本次沒有新內容 / 首次建立本地 main」。

### 輸出範本

```
✅ 已更新到最新版本

📍 你現在在: <branch>（進行中的草稿已還原）
🔄 main 更新: <BEFORE 短碼> → <新短碼>（快進 N 個 commit）

這次多了什麼:
• 線上現況更新: <幾支 specs/frontend 規格，列重點>
• 其他人的草稿: <哪些 sprint / feature>
• 封存區: <archive/ 有無更新>

（若有）⚠️ 待你處理: <stash pop 衝突 / 併入 main 衝突 / main 分岔>
```

已是最新時省略更新明細,直接回「目前已是最新版,沒有需要拉的更新」。

---

## 撰寫規則

- 繁體中文為主,技術名詞(欄位名、狀態 enum、分支名)保留英文。
- 對象是 PM:少講 git 術語,多講「多了哪些規格、你的草稿還在不在」。
- 摘要聚焦**規格內容差異**,不列 migration / 部署細節。

## 重要提醒

- **只拉不推**:本指令不 push、不開 PR、不改遠端;要送出草稿走 [`/ship`](ship.md)。
- **不丟資料**:一律先保護 WIP(commit 或 stash)再更新;禁用 `reset --hard` / 覆蓋式 checkout。
- **不硬解衝突**:併入 main 或還原暫存遇衝突,列清楚交給使用者,別自行拍板。
- 平台 Gitea,目標分支固定 `main`(此 repo 沒有 `develop`)。
- 現況四區(`specs/` `frontend/` `routes/` `userflows/`)本來就是別的 repo 同步進來的——sync 只是把它們的最新版拉下來看,不是在這裡改它們。
