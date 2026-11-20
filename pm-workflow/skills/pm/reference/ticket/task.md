# 工作票

技術工作、調查、資料修補、日常任務（Task 類型）。

---

## Step 0：資訊確認

若以下資訊缺少，**一次問清楚**：

- **任務描述**（必填）：要做什麼？
- **Environment**：`Dev` / `Alpha` / `Beta` / `Production`（不確定則問）
- **Due date**（未提供預設今天 +7 天）
- **Team**（必填）：這張票要算在哪個 team 名下？不可預設任何 team

⚠️ **不要在這裡先問「負責 RD 是誰」。** Subtask 一律先建立（預設不指派），建立完成後才在 Step 5 詢問要指派給誰。

---

## Step 1：判斷 Epic

讀取 `references/epic-mapping.md` 找出 Epic Key。

若屬於技術調查、無明確模組歸屬 → 後端用 `PROJ-104`（後端 Backlog）、前端用 `PROJ-105`（前端 Backlog）。

---

## Step 2：決策並請使用者確認

列出：
- `summary`：格式 `[模組] 描述`，50 字以內
- `Epic Key`
- `priority`（預設 `Medium`）
- `environment`
- Subtask 規劃

---

## Step 3：取得當前 Sprint

呼叫 `searchJiraIssuesUsingJql`：
```
project = PROJ AND sprint in openSprints()
```

---

## Step 4：建立主票

呼叫 `createJiraIssue`：
```
cloudId:       {站台 GUID，見 SKILL.md 共用常數}
projectKey:    SD
issueTypeName: Task
summary:       [模組] 描述
contentFormat: adf
description:   （見下方 ADF 格式）
assignee:      開票者自己
parent:        {Epic Key}
additional_fields:
  <CUSTOM_FIELD_ID>: "{使用者確認的 team ID}"
  <CUSTOM_FIELD_ID>: {environment}
  <CUSTOM_FIELD_ID>: {Sprint ID 整數}
```

description 使用 `references/adf-templates.md` 的「工作票（Task）」範本，填入實際內容。

---

## Step 5：處理 Subtask

> ⚠️ **必須先查再決定**，不可直接建立。

呼叫 `getJiraIssue` 取得主票，檢查 `subtasks` 欄位：
- **已有 Subtask** → 呼叫 `editJiraIssue` 更新 `priority`、`dueDate`
- **沒有 Subtask** → 直接呼叫 `createJiraIssue` 建立，**不要事先詢問要指派給誰**：
  - `issueTypeName`: `Sub-task`
  - `parent`: 主票 Key
  - `summary`: 預設與主票 `summary` 相同
  - `assignee`: 預設不指派

Subtask 建立完成後，才詢問使用者「這個 Subtask 要指派給誰？（預設不指派）」，若使用者回覆才用 `editJiraIssue` 補上 `assignee`。

回報主票與 Subtask 連結：`https://your-team.atlassian.net/browse/PROJ-XXXXX`
