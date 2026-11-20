# 簡道雲情境

由上游的通報自動化（`webpage-to-jira`，未收錄於本 repo） 分析完畢後傳入，直接建立 Jira 票。

接收的資訊：
- 通報資訊（通報編號、品牌、站臺、訂單編號、揀貨單編號、問題描述）
- 票型：Bug / Task / Story（優化票）
- Priority
- Epic Key

> 此情境為自動化流程、非即時對話，`<CUSTOM_FIELD_ID>`（team）維持預設 `<TEAM_NAME>`（`"<NOTION_ID>"`），不套用「全局規則：Team 欄位」的每次詢問要求。

---

## Step 1：取得當前 Sprint

呼叫 `searchJiraIssuesUsingJql`：
```
project = PROJ AND sprint in openSprints()
```
取得 Sprint ID（`<CUSTOM_FIELD_ID>` 的整數值）。

---

## Step 2A：建立 Bug / Task 主票

適用票型：Bug、Task

呼叫 `createJiraIssue`：
```
cloudId:       {站台 GUID，見 SKILL.md 共用常數}
projectKey:    SD
issueTypeName: Bug 或 Task
summary:       [模組] 描述（繁體中文，50字以內）
contentFormat: markdown
description:   （見下方格式）
assignee:      開票者自己
parent:        {Epic Key}
additional_fields:
  <CUSTOM_FIELD_ID>: "<NOTION_ID>"
  <CUSTOM_FIELD_ID>: "Production"
  <CUSTOM_FIELD_ID>: {Sprint ID 整數}
```

**description 格式：**
```markdown
## 通報資訊
- 通報編號：#XXX
- 品牌：{品牌}｜站臺：{站臺}
- 訂單編號：{訂單編號}（若有）
- 揀貨單編號：{揀貨單編號}（若有）

## 問題描述
{原始描述，保留原文}

## 重現步驟
（若已知，從描述中整理）

## 預期行為
（若已知）

## 實際行為
（問題現象）
```

---

## Step 2B：建立優化 Story 票

適用票型：Story（UI/UX 優化、體驗改善）

呼叫 `createJiraIssue`：
```
cloudId:       {站台 GUID，見 SKILL.md 共用常數}
projectKey:    SD
issueTypeName: Story
summary:       [模組] 描述（繁體中文，50字以內）
contentFormat: adf
description:   （見下方 ADF 格式）
assignee:      開票者自己
parent:        {Epic Key}
additional_fields:
  <CUSTOM_FIELD_ID>: "<NOTION_ID>"
  <CUSTOM_FIELD_ID>: "Production"
  <CUSTOM_FIELD_ID>: {Sprint ID 整數}
```

**description ADF 格式：**
```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "panel",
      "attrs": { "panelType": "info" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "背景：", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "（說明現況、問題根源）" }
          ]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "通報資訊 / Report Info" }]
    },
    {
      "type": "bulletList",
      "content": [
        { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "通報編號：#XXX" }] }] },
        { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "品牌：XXX｜站臺：XXX" }] }] },
        { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "訂單編號：XXX（若有）" }] }] }
      ]
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "問題描述 / Problem Statement" }]
    },
    { "type": "paragraph", "content": [{ "type": "text", "text": "（保留原始描述）" }] },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "優化目標 / Goals" }]
    },
    { "type": "bulletList", "content": [] },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "提案方向 / Proposed Solutions" }]
    },
    { "type": "orderedList", "content": [] },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "驗收條件 / Acceptance Criteria" }]
    },
    { "type": "bulletList", "content": [] }
  ]
}
```

---

## Step 3：處理 Subtask

> ⚠️ **必須先查再決定**，不可直接建立。

呼叫 `getJiraIssue` 取得主票，檢查 `subtasks` 欄位：
- **已有 Subtask** → 呼叫 `editJiraIssue` 更新 `priority`、`dueDate`、`assignee`
- **沒有 Subtask** → 呼叫 `createJiraIssue` 建立：
  - `issueTypeName`: `Sub-task`
  - `parent`: 主票 Key
  - `summary`: 預設與主票 `summary` 相同
  - `assignee`: 後端預設 <後端負責人>、前端預設 <前端負責人>

回傳主票 URL 給上游自動化繼續執行 Step 6（回寫簡道雲）。
