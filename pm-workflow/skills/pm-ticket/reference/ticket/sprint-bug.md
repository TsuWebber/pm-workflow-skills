# Type 3：Sprint Bug 票

Sprint 測試期間發現的 bug，掛在對應 Epic 的 `[QA] 測試BUG專區` 底下。

---

## Step 0：資訊確認

若以下資訊缺少，**一次問清楚**：

- **Bug 描述**（必填）：現象、重現步驟、預期行為
- **所屬 Epic**（必填）：這個 bug 屬於哪個功能的 Sprint？（提供 Epic Key 或名稱）
- **priority**（選填，不確定則預設 `Medium`）
- **Due date**（選填，未提供預設今天 +3 天）

---

## Step 2：找到 `[QA] 測試BUG專區`

呼叫 `searchJiraIssuesUsingJql`：
```
parent = {EPIC_KEY} AND summary ~ "[QA] 測試BUG專區"
```

取得 `[QA] 測試BUG專區` 的 Issue Key（以下稱 `BUG_AREA_KEY`）。

若找不到，通知使用者該 Epic 尚未建立 bug 專區，詢問是否要先執行 Type 2 流程。

---

## Step 3：決策並說明理由，請使用者確認後建單

- **`summary`**：繁體中文，格式 `[BUG] 描述`，50 字以內
- **`priority`**：使用者提供或預設 `Medium`
- **`dueDate`**：`YYYY-MM-DD`

---

## Step 4：建立 Bug Subtask

呼叫 `createJiraIssue`：
- `issueTypeName`: `Sub-task`
- `parentKey`: `BUG_AREA_KEY`
- `contentFormat`: `adf`
- `summary`、`priority`、`dueDate`
- `cloudId`、`projectKey` 參照 SKILL.md 共用常數

description 使用 `references/adf-templates.md` 的「Sprint Bug Subtask」範本，填入實際內容。

回報建立的 Bug Key + URL。
