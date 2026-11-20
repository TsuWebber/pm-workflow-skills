# pm-launch sync-code — 把後端／前端的變更吸收進規格

> 這條指令的方向是 **程式碼 → 規格**：讀 oms（Laravel 後端）與 frontend（nx 前端）
> master 上的變更，把「規格還沒寫到的行為與測資」補進 `specs/docs/<模組>/stories/`。
>
> 跟 [`pm-setup sync`](../../pm-setup/reference/sync.md) 不一樣：那條是從 Gitea 拉別人寫的規格，這條是從程式碼反推規格。
>
> **這條指令不會自動 commit、不會 push、不會開 PR。** 寫完檔案就停，讓人先看過。
> 要送出去用 [`pm-ship`](../../pm-ship/reference/ship.md) 或 [`pm-ship（開 PR 步驟）`](../../pm-ship/reference/pr.md)。

## 水位線（為什麼需要 commit hash）

`.spec-sync-state.json` 記錄 specs/ 已經吸收到哪一個 master commit。每次跑完更新它。

**用 hash 不用日期**：合併時間與提交時間經常差好幾天（有人 8/10 開分支、8/20 才合進 master），
用「某日之後」去撈會漏掉這種變更。`git log <hash>..origin/master` 是 DAG 上的區間，保證不重不漏。

## 前置檢查（做不到就停下來問，不要猜）

1. **repo 路徑**：從 `.spec-sync-state.json` 讀 `repos.*.path`（`~` 要展開）。
   - **確認 remote 是 GitHub `<ORG>/*`**。若不是就停下來報告。
   - ⚠️ `~/oms` 是舊的 GitLab clone（`<OLD_ORG>/oms`），**已無法存取，絕對不要用**。
     oms 一律用 `~/infrastructure/repositories/oms`。
2. **不要動使用者的工作分支**：只 `git fetch origin master`，然後一律以 `origin/master` 做比較。
   **禁止** `git checkout` / `git switch` / `git pull` / `git stash` / `git reset` —— 使用者可能正開著功能分支在寫東西。
3. **spec repo 這邊**：`git status --porcelain` 若有未提交變更，列出來讓使用者確認要不要在這個狀態上疊。
4. 確認 `specs/docs/SPEC-WRITING-GUIDELINES.md` 存在 —— 那是唯一依據。

## 步驟

### 1. 算出這次要看的區間

```bash
git -C <repo> fetch -q origin master
git -C <repo> log --oneline <synced_to>..origin/master | wc -l
```

`--since <commit>` 可覆蓋水位線（補撈或重跑用）。`--repo` 只跑其中一個。

若兩邊都是 0 筆，回報「已是最新」後結束，**不要更新水位線以外的任何東西**。

### 2. 切成 ticket 級的工作單位

**不要依賴 commit message。** 只有少數 non-merge commit 帶得上 Jira 票號，訊息也不保證可信。
做法是從 **merge commit 的分支名**反推 ticket：

```bash
git -C <repo> log --merges --format='%H%x09%s' <since>..origin/master
# "Merge pull request #418 from <ORG>/PROJ-101" → ticket = PROJ-101
```

同一個 ticket 有多個 merge 時，取**檔案數最少**的那個當代表 diff（那通常是真正的實作，
其餘是 rebase／回合主線的噪音）。

**排除 rollup merge**：分支名含 `epic/`、`worktree`，或改動檔案數 > 150 的 merge。
那些是把一堆 ticket 一次合進來，diff 沒有辨識度。**排除掉幾筆要在報告裡講**，不要默默丟。

沒有 merge commit 對應的 non-merge commit（直推 master）也要收進來，各自當一個工作單位。

### 3. 路由到模組

每個模組的 `_index.md` 末尾有「程式碼對照表」。**每次執行都重新從那些表建一份 class name → 模組
的字典**（不要用寫死的表，模組會增減）：

```bash
# 從所有 _index.md 的程式碼對照表抽出 class 名 → 模組
```

一個 ticket 的 diff 依序用三種訊號決定模組：
1. 改動檔案的 class name 命中字典
2. 路徑 glob（`app/Services/Coupon/*` → `05-product-and-marketing/coupon` 之類）
3. 兩者都不中 → 交給 agent 讀 diff 判斷，並在報告裡標記「靠判斷路由」

**同一個 ticket 可以落在多個模組**，不要強迫只選一個。

### 4. 用 SPEC-WRITING-GUIDELINES.md 過濾（這是唯一依據）

**不要自己發明評分機制。** `specs/docs/SPEC-WRITING-GUIDELINES.md` 就是判斷矩陣：

- §零 決定「這段程式碼要不要看」（非排程 Command、DataMigration、死程式碼 → 不看）
- §一／§二 決定「要不要寫 Scenario」
- §三 灰色地帶的判斷流程
- §四 撰寫風格 —— 業務語言，不寫 class 名／欄位名／**我們回給前端的錯誤碼與 HTTP 狀態碼**

### 5. 寫進 stories/

- 檔名 `{業務主題-kebab-case}.feature.md`
- 已有對應 story 就**改寫既有 Scenario**，不要另開一個檔案講同一件事
- 新檔要登記進該模組的 `stories/_index.md`，而且**照那個模組原有的表格格式**
  （各模組欄位不統一：有帶 `狀態` 欄的、有帶 `Actor` 欄的、有 Activity 分組的、有主題分節的
  —— 不要強行統一成一種）
- 有「涵蓋範圍」對照表的模組，也要補上對應列

### 6. 驗證（跳過這步等於白做）

**每一條新寫或改寫的 Given/Then 具體值，都要回 master 查證。** 這是實測有效的：有做這件事的
agent 錯誤率接近 0，沒做的是 12–26%。

查不到就寫 `TBD（規格未明）`，**不要自己編一個值填上去**。

### 7. 完整性檢查

```bash
# 每個 .feature.md 的 ``` 必須是偶數
# 每個 stories/*.feature.md 都要出現在該模組 stories/_index.md
# 所有相對 markdown 連結都要指到存在的檔案（注意 ../ 的層數）
```

### 8. 更新水位線

把 `synced_to` 更新成這次比對的 `origin/master` HEAD，補一筆 `_history`。
`--dry-run` 時**不要**更新。

## 已知陷阱（都是踩過的）

1. **「值存在」不等於「值在這個情境下被用到」**。確認一個常數／Job／方法真的有呼叫端，
   再拿它寫規格。曾經把一個零呼叫端 Job 的重試參數寫成規格。
   → 查完 `grep <名稱>` 還要看命中的是定義還是**使用**。

2. **常數名會騙人**。`COUPON_EXPIRED` 的實際訊息是 `'Coupon is not enabled.'`。
   → 要同時看常數名、拋出點的訊息字串、以及該情境的前置條件三者。

3. **刪除或改寫既有 Scenario 前，把該判定的程式碼段完整讀出來。** 只看一個 grep 命中就下結論會出錯。
   不確定就問，不要直接改。

4. **描述已失效的機制時說「這條機制不再生效」，不要推論成「機制被移除」** —— 除非真的查到刪除。

5. **有條件的行為不要寫成無條件的**。曾經有 6 條 Scenario 少寫了「下單日是工作日」這個前置條件。

6. **Examples 不要用不可能出現的值**。要確認那個值真的能被設定、而且真的會產生那個結果
   （前端 zod 的下限常常跟後端 validation 不一樣）。

7. **掃描用寬鬆條件再人工分類，不要用窄 regex 求精準。** 找殘留的錯誤碼時，
   窄 regex 連續漏了兩輪（`錯誤碼 25002`、`狀態碼為 403` 都漏掉）。

8. **注意跨模組相對連結的 `../` 層數。** 從 `docs/06-x/member/` 連到 `docs/05-y/` 要 `../../`。

9. **不可達的分支不要寫。** 兩個 `if` 丟同一個錯誤碼時，先確認後面那個不是前面的子集。

## 活用 agent

ticket 數量多時分批派 agent，每批 ≤ 25 個 ticket、按模組分組。給每支 agent 的 prompt 要含：

- **禁止用 Agent / Task 工具轉派** —— 曾經有 agent 把工作再分派出去，結果沒人收集回來
- **禁止** `git commit` / `checkout` / `restore` / `reset`
- 要求回報：逐筆處置表、逐條「原本 vs 改為」（原文照貼，不要只描述）、量化
  （可查證斷言 N 條 / 實際查證 N 條 / 寫成 TBD N 條）、以及**未處理與要問的**
- 明確要求：**不確定就回報問，不要編**

**agent 回報成功不等於沒問題**。完整性檢查每次都要跑，不是只在 agent 掛掉時跑。
agent 之間互相矛盾時，通常是**讀了完整程式碼段**的那個對。

## 產出報告

1. 這次的區間（兩個 repo 的 `<since>..<head>`）與 ticket 數
2. 排除掉的 rollup merge（幾筆、為什麼）
3. 逐模組：新增幾個 story 檔、改寫幾處
4. **訂正了什麼**（原本寫錯，不只是沒寫）—— 這段最重要，會影響已經在用規格的人
5. 量化：可查證斷言 N 條 / 實際查證 N 條 / `TBD（規格未明）` N 條
6. 完整性檢查結果
7. **順帶發現的程式碼缺陷**（規格與程式不符、死程式碼、前後端驗證不一致…），列出來讓 PM 決定
   是修程式還是規格以現況為準 —— 不要自己開票
