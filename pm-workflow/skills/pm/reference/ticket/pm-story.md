# Type 2：PM User Story 票

PM 提供 Notion spec 連結，批次建立 Epic + User Story 票。

---

## Step 0：資訊確認

若以下資訊缺少，**一次問清楚**：

- **Notion 連結**（必填）
- **Sprint**（選填）
- **Due date**（選填，未提供預設今天 +14 天）
- **Team**（必填）：Epic 與所有 Story 要算在哪個 team 名下？不可預設任何 team

---

## Step 1：讀取 Notion 頁面

呼叫 Notion 的 `notion-fetch`，傳入使用者的 Notion 連結。

從頁面中擷取：
1. **標題**（作為 Epic summary）
2. **User Story 表格**（通常標題為 `## User Story`）：取每列的「功能摘要」欄位作為 Story summary，忽略標題列和分類列（色塊標題列）
3. **背景描述**（作為 Epic description，取 Background 段落）

---

## Step 2：列出建票計畫請使用者確認

建單前先列出：

**Epic：**
- summary：`[專案名稱]`（Notion 頁面標題）
- description：Background 段落內容

**Stories：**（列表呈現，每列一張）
- 各 User Story 的 summary

**固定區域票（每個 Epic 都要建）：**
- `[QA] 測試BUG專區`（Bug）
- `[PM] 規格增補區`（Story）
- `[UI] 體驗優化專區`（Task）

確認後執行 Step 3。

---

## Step 3：建立 Epic

呼叫 `createJiraIssue`：
- `issueTypeName`: `Epic`
- `summary`: Notion 頁面標題
- `description`: Background 段落
- `cloudId`、`projectKey` 參照 SKILL.md 共用常數；`team` 用 Step 0 使用者確認的 team
- `sprint`、`dueDate`：若有則填入

記下建立的 Epic Key。

---

## Step 4：批次建立 User Story 票

對每個 User Story，呼叫 `createJiraIssue`：
- `issueTypeName`: `Story`
- `parentKey`: Step 3 的 Epic Key
- `summary`: User Story 功能摘要
- `team`: Step 0 使用者確認的 team
- `priority`: 依 Notion 表格的優先級欄位（P0 → `Highest`、P1 → `High`、P2 → `Medium`、P3 → `Low`，空白 → `Medium`）
- `dueDate`、`sprint`：同 Epic

---

## Step 4.5：為每個 User Story 建立 Subtask

⚠️ **每張 Story 都必須有 Subtask，不存在「不開 Subtask」的情境。**

對 Step 4 建立的每一張 Story，呼叫 `createJiraIssue` 建立 Subtask：
- `issueTypeName`: `Sub-task`
- `parent`: 該 Story 的 Key
- `summary`: 預設與該 Story 的 `summary` 相同
- `assignee`: 預設不指派，**不要事先詢問要指派給誰**

全部建立完成後，才一次詢問使用者「這些 Subtask 要指派給誰？（預設不指派）」，使用者回覆才用 `editJiraIssue` 逐一補上 `assignee`。

---

## Step 5：建立固定區域票

對以下三張，依序呼叫 `createJiraIssue`（`issueTypeName` 對應下表的 `issueType` 欄）：

| summary | issueType | priority |
|---------|-----------|---------|
| `[QA] 測試BUG專區` | `Bug` | `Medium` |
| `[PM] 規格增補區` | `Story` | `Medium` |
| `[UI] 體驗優化專區` | `Task` | `Low` |

- `parentKey`: Step 3 的 Epic Key

---

## Step 6：回報結果

回報：
- Epic Key + URL
- 所有建立的 Story Key 清單
- 三個區域票 Key
