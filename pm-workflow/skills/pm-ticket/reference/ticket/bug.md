# Bug 票

功能異常、不符預期行為（非 Sprint 測試期間）。

---

## Step 0：資訊確認

若以下資訊缺少，**一次問清楚**：

- **Bug 描述**（必填）：現象是什麼？
- **重現步驟**（必填）：如何重現？
- **預期 vs 實際行為**
- **Environment**：`Dev` / `Alpha` / `Beta` / `Production`（預設 Production）
- **Due date**（選填；未提供則依 priority 自動計算，跳過週六日，若落假日順延至下個工作日；使用者有指定則優先使用）
  - `Highest` → 今天 +3 個工作天
  - `High` → 今天 +5 個工作天
  - `Medium` → 今天 +7 個工作天
  - `Low` → 今天 +14 個工作天
  - `Lowest` → 今天 +30 個工作天
- **是否有截圖或錯誤訊息**
- **Sprint**：每張票都必須帶入當前 Sprint ID（必填）
- **Team**（必填）：這張票要算在哪個 team 名下？不可預設任何 team

---

## Step 1：判斷 Epic & Priority

讀取 `references/epic-mapping.md` 找出 Epic Key。

Priority 判斷：
| 程度 | Priority |
|------|---------|
| 系統無法使用、影響所有用戶 | `Highest` |
| 主要功能受損、影響大量用戶 | `High` |
| 部分功能受損，有 workaround | `Medium` |
| 小問題、體驗瑕疵 | `Low` |

---

## Step 2：決策並請使用者確認

列出：
- `summary`：50 字以內，開頭格式依責任方：
  - 後端：`[BE] 描述`
  - 前端：`[FE] 描述`
  - 前後端都有：`[模組] 描述`
- `Epic Key`
- `priority`
- `environment`
- Subtask 規劃（前端 or 後端？）
  - 後端：`[BE] 描述`
  - 前端：`[FE] 描述`
  - 前後端都有：`[模組] 描述`，分別建立兩張 Subtask

---

## Step 3：取得當前 Sprint

⚠️ **每張票都必須重新執行此查詢，不可沿用同 session 中上一張票的結果。**

呼叫 `searchJiraIssuesUsingJql` 取得 Sprint ID（整數）：
```
project = PROJ AND sprint in openSprints()
```
取第一筆的 Sprint ID，填入 `<CUSTOM_FIELD_ID>`。

---

## Step 4：建立主票

呼叫 `createJiraIssue`：
```
cloudId:       {站台 GUID，見 SKILL.md 共用常數}
projectKey:    SD
issueTypeName: Bug
summary:       [模組] 描述
contentFormat: adf
description:   （見下方 ADF 格式）
assignee:      開票者自己
parent:        {Epic Key}
additional_fields:
  <CUSTOM_FIELD_ID>: "{使用者確認的 team ID}"
  <CUSTOM_FIELD_ID>: {"value":"{environment}"}
  <CUSTOM_FIELD_ID>: {Sprint ID 整數}
  priority:          {"name": "{priority}"}
  duedate:           "YYYY-MM-DD"
```
`<CUSTOM_FIELD_ID>` 填入 environment，格式：`{"value": "Production"}`（允許值：`Dev` / `Alpha` / `Beta` / `Production`）
`<CUSTOM_FIELD_ID>` 填入 Sprint ID（整數），格式：`{"<CUSTOM_FIELD_ID>": SPRINT_ID}`（純數字，不可用物件格式）
description 使用 `references/adf-templates.md` 的「Bug 票」範本，填入實際內容。

---

## Step 5：處理 Subtask

⚠️ **必須先查再動**：一定要先呼叫 `getJiraIssue` 取得主票的 `subtasks` 欄位，**不可直接建立 Subtask**。**即使是剛建立的主票也不得省略此步驟。**

- **有 Subtask** → 用 `editJiraIssue` 更新 `priority`、`dueDate`，不要新建，**不要修改 summary**
- **沒有 Subtask** → 直接用 `createJiraIssue` 建立，`issueTypeName: Sub-task`，`parent` 為主票 Key，**不要事先詢問要指派給誰**
- **Subtask 的 `summary`**：預設與主票 `summary` 相同
- **Subtask 的 `assignee`**：建立時預設**不指派**。建立完成後才詢問使用者要指派給誰，使用者回覆才用 `editJiraIssue` 補上 `assignee`

回報主票與所有 Subtask 的連結，直接輸出純網址（不用 Markdown 連結格式），讓使用者在 terminal 可以 cmd+左鍵直接開啟：

```
主票：https://your-team.atlassian.net/browse/PROJ-XXXXX
Subtask：https://your-team.atlassian.net/browse/PROJ-XXXXX
```
