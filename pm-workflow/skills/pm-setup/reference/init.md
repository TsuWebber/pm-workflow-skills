# init：建立專案背景

在目前工作目錄建立或更新 `.pm/PROJECT.md`，讓之後每個 pm-* skill 指令都有一致的專案背景可讀。

---

## Workflow

### Step 1：先自己找，不先問

依序檢查，能填的先填：
- 目前工作目錄的檔名、資料夾名、既有 `.md` 文件（PRD 草稿、決策文件、會議記錄）
- 對話中已出現的 Notion / Jira / Figma 連結
- 全域 `CLAUDE.md` 的產品線、系統、部門定義
- 若已有 `.pm/PROJECT.md` → 讀取，這次是**更新**，只補缺口與過期內容

### Step 2：只問真正的缺口

把模板中仍空白、且會影響後續指令的欄位整理成問題，**一次最多 5 題**，依重要性排序：
1. 產品線與涉及系統（影響 `pm-review edge` / `pm-review impact`）
2. 使用單位 / TA（影響 `pm-launch release` / `pm-review readers`）
3. 相關部門與決策者（影響 `pm-review impact` / `pm-plan decide`）
4. Jira Epic（影響 `pm-ticket`）
5. 主要 baseline 數字（影響 Success Metrics）

使用者答不出來的欄位，填 `🟡 待確認`，不要卡住。

### Step 3：寫檔

依 `templates/PROJECT.md` 結構寫入 `.pm/PROJECT.md`。
- 沒資訊的欄位整列刪除，不留空白列；但「名詞補充」「已知限制」即使空也保留標題，方便之後補。
- 更新既有檔案時，只改有變的欄位，並更新「最後更新」日期。

### Step 4：回報

一兩句話說明：檔案位置、填了哪些、還有幾個 `🟡 待確認`。
接著建議下一步：要寫規格就用 `pm-plan scope` / `pm-spec write`，要做決策文件就用 `pm-plan decide`。

---

## 規則

- `.pm/PROJECT.md` 只放**這個專案特有**的資訊；公司共用知識留在全域 `CLAUDE.md`，不重複抄寫。
- 不寫入 Notion，這是本機檔案。
