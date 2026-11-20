# Type 1：Tech 票

日常 task、bug、工程需求。

---

## Step 0：資訊確認

若以下資訊缺少且無法推斷，**一次問清楚**：

- **需求描述**（必填）
- **Environment**：`Dev` / `Alpha` / `Beta` / `Production`（描述中有提則自動帶入；不確定則問使用者）
- **Due date**（選填，未提供預設今天 +7 天）
- **Sprint**：依 `types.md` 的全局規則決定要不要帶當前 Sprint（要帶時呼叫 `searchJiraIssuesUsingJql` 以 `project = <PROJECT_KEY> AND sprint in openSprints()` 取得，field: `<CUSTOM_FIELD_ID>`）
- **Team**：依 `types.md` 的全局規則，每張票都要問，不預設
- **負責 RD**：前端 or 後端？指定誰？（不知道則後端預設 <後端負責人>、前端預設 <前端負責人>）
- **QA**：由誰測試？（不確定略過；不需測試則掛開票者自己）

---

## Step 1：對照開票地圖，找出 Epic Key

讀取 `references/epic-mapping.md`，根據需求描述找出最相關的 Epic Key。

> 補充：訂單資料欄位問題、異動紀錄、全通路建單 → **全通路訂單（PROJ-106）**

---

## Step 2：決策並說明理由

列出以下判斷，請使用者確認後再建單：

- **`parentKey`**：Step 1 找到的 Epic Key
- **`issueType`**：
  - `Bug` → 功能異常、不符預期
  - `Story` → 新功能、需求改善
  - `Task` → 技術工作、調查、資料修補
- **`priority`**：
  - `Highest` → 系統無法使用、影響所有用戶
  - `High` → 主要功能受損、影響大量用戶
  - `Medium` → 部分功能受損，有 workaround
  - `Low` → 小問題、體驗瑕疵
  - `Lowest` → 優化、nice-to-have
- **`environment`**：`Dev` / `Alpha` / `Beta` / `Production`（對應 `<CUSTOM_FIELD_ID>`）
- **`summary`**：繁體中文，格式 `[模組] 描述`，50 字以內
  - 明確只有前端：`[FE] 描述`
  - 明確只有後端：`[BE] 描述`
- **`description`**：使用者原始敘述，保留原文
- **`dueDate`**：`YYYY-MM-DD`
- **`sprint`**：若有則填入
- Subtask 規劃：每張 Story/Bug 都需要 FE 或 BE Subtask，priority/dueDate 同主票

---

## Step 3：建立主票

呼叫 Jira MCP 的 `createJiraIssue`：
- `cloudId`、`projectKey`、`team`、`environment` 參照 SKILL.md 共用常數
- `summary`、`issueTypeName`、`priority`、`parentKey`、`description`、`dueDate`
- `additional_fields` 的 `<CUSTOM_FIELD_ID>` 填入 Sprint ID（整數），格式：`{"<CUSTOM_FIELD_ID>": SPRINT_ID}`（純數字，不可用物件格式）
- `additional_fields` 包含：`<CUSTOM_FIELD_ID>`（team）、`<CUSTOM_FIELD_ID>`（environment，若有）
- ⚠️ `<CUSTOM_FIELD_ID>` 的值必須是**純字串 ID**，不可用 `{"name": "..."}` 或 `{"id": "..."}` 物件格式
  - `<TEAM_NAME>` 的 ID：`"<NOTION_ID>"`
- `description` 必須使用**實際換行符**，不可用字串 `\n`；`contentFormat` 設為 `markdown`
- **`assignee`**：主票 assign 給**開票者自己**，不是 RD

---

## Step 4：處理 Subtask

> ⚠️ **必須先查再決定**，不可直接建立。

呼叫 `mcp__claude_ai_Atlassian__getJiraIssue` 取得主票，檢查 `subtasks` 欄位：
- **已有 Subtask** → `mcp__claude_ai_Atlassian__editJiraIssue` 更新 `priority`、`dueDate`、`assignee`
- **沒有 Subtask** → `mcp__claude_ai_Atlassian__createJiraIssue` 建立：
  - `issueTypeName`: `Sub-task`
  - `parent`: 主票 Key
- **Subtask 的 `assignee`**：才是負責的 RD（後端預設 <後端負責人>、前端預設 <前端負責人>）

回報主票與所有 Subtask 的連結，格式為 `https://your-team.atlassian.net/browse/{{issueKey}}`。
