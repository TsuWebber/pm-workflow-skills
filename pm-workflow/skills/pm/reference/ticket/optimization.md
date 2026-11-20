# 優化票

涵蓋兩種子類型，建票時先詢問或從上下文判斷：

| 子類型 | 觸發情境 | 標題格式 |
|--------|---------|---------|
| **一般優化票** | UI/UX 優化、體驗改善、流程重構 | `[模組] 描述` |
| **配套溝通票** | 跨部門配套、功能決策溝通、含前一張票的延續 | `【配套溝通】【模組】描述` |

---

## Step 0：資訊確認

若以下資訊缺少，**一次問清楚**：

- **問題描述**（必填）：現況有什麼不好？
- **期望目標**：改善後要達到什麼？
- **子類型**：一般優化 or 配套溝通？
- **配套溝通票專用**：
  - 前一張票連結（延續自哪裡）
  - 先前已處理了什麼
  - 本次要處理的清單（本 Sprint）
  - 還需要達到的清單（Backlog）
- **Due date**（未提供預設今天 +14 天）
- **Team**（必填）：這張票要算在哪個 team 名下？不可預設任何 team

---

## Step 1：Epic

優化票統一掛在 **QA Backlog（PROJ-103）**，不需判斷模組 Epic。

---

## Step 2：決策並請使用者確認

列出：
- `summary`（含標題格式）
- `Epic Key`：PROJ-103（QA Backlog）
- 票型（Story）
- description 結構預覽

---

## Step 3：建立 Story 票（ADF）

description 使用 `references/adf-templates.md` 的「優化票（Story）— 一般優化」範本，填入實際內容。

---

description 依子類型選擇：
- 一般優化 → `references/adf-templates.md` 的「優化票（Story）— 一般優化」範本
- 配套溝通票 → `references/adf-templates.md` 的「優化票（Story）— 配套溝通票」範本

呼叫 `createJiraIssue`：
```
cloudId:       {站台 GUID，見 SKILL.md 共用常數}
projectKey:    SD
issueTypeName: Story
summary:       （依子類型格式）
contentFormat: adf
description:   （填入實際內容）
assignee:      開票者自己
parent:        PROJ-103
additional_fields:
  <CUSTOM_FIELD_ID>: "{使用者確認的 team ID}"
  （<CUSTOM_FIELD_ID> 不填，除非 User 明確要求排入 Sprint）
```

---

## Step 4：處理 Subtask

⚠️ **每張主票都必須有 Subtask，不存在「不開 Subtask」的情境。**

> ⚠️ **必須先查再動**：先呼叫 `getJiraIssue` 取得主票的 `subtasks` 欄位，不可直接建立。

- **已有 Subtask** → 用 `editJiraIssue` 更新 `priority`、`dueDate`，不要新建
- **沒有 Subtask** → 直接用 `createJiraIssue` 建立，`issueTypeName: Sub-task`，`parent` 為主票 Key，`summary` 預設與主票 `summary` 相同，`assignee` 預設不指派，**不要事先詢問要指派給誰**

Subtask 建立完成後，才詢問使用者要指派給誰（預設不指派），使用者回覆才用 `editJiraIssue` 補上 `assignee`。

回報主票與 Subtask 連結：`https://your-team.atlassian.net/browse/PROJ-XXXXX`
