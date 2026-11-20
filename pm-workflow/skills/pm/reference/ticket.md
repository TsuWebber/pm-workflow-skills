# ticket：建立 Jira 工單（原 jira-create-ticket）

> 路徑說明：本檔提到的票型檔都在 `reference/ticket/`。票型檔內寫的 `references/xxx.md` 指 `reference/ticket/references/xxx.md`。

幫我建立 Jira 工單。

## 判斷開票情境

根據使用者的描述或上游 skill 傳入的資訊，判斷屬於哪種情境，讀取對應的規格檔並照著執行：

| 情境 | 判斷條件 | 規格檔 |
|------|---------|--------|
| **簡道雲** | 由上游的通報自動化（`webpage-to-jira`，未收錄於本 repo） 傳入已分析的通報資料 | `ticket/jiandaoyun.md` |
| **Bug 票** | 功能異常、不符預期、錯誤（非 Sprint 測試期間） | `ticket/bug.md` |
| **Sprint Bug 票** | Sprint 測試期間發現的 bug，需掛在 Epic 的 bug 專區 | `ticket/sprint-bug.md` |
| **需求票** | 附有 Notion spec 連結，需要批次建立 Epic + Story | `ticket/pm-story.md` |
| **優化票** | UI/UX 優化、體驗改善、配套溝通 Story | `ticket/optimization.md` |
| **工作票** | 技術工作、調查、資料修補、日常任務（Task） | `ticket/task.md` |

若無法判斷，直接問使用者是哪種情境。

判斷後，用 Read 工具讀取對應的 md 檔，並照著該檔的流程執行。

---

## 全局規則：Subtask

**每張主票（Bug / Task / Story，含優化票）建立後都必須建立至少一張 Subtask，不存在「不開 Subtask」的情境。**

流程統一為：先查（`getJiraIssue` 檢查 `subtasks`）→ 沒有才建（`issueTypeName: Sub-task`，`summary` 預設與主票 `summary` 相同，`assignee` 預設不指派）→ 建完才問使用者要指派給誰，**不要在建立前先問**。已有 Subtask 則用 `editJiraIssue` 更新，不新建、不改 summary。

例外：Epic、以及 pm-story.md 中批次建立的三張固定區域票（`[QA] 測試BUG專區`／`[PM] 規格增補區`／`[UI] 體驗優化專區`）本身是容器票，暫不視為需要立即建 Subtask 的情境。

---

## 全局規則：Team 欄位

**`<CUSTOM_FIELD_ID>`（team）不可預設帶入 `<TEAM_NAME>`，每張票建立前都必須詢問使用者這張票要算在哪個 team 名下。**

在 Step 0 資訊確認時一併問：「這張票要算在哪個 team？」。使用者未回答前不建票。若使用者當下答不出精確 team 名稱，可先列出已知選項（例如 `<TEAM_NAME>`）供選擇。

例外：`ticket/jiandaoyun.md` 情境是由上游的通報自動化（`webpage-to-jira`，未收錄於本 repo） 自動化傳入、非即時對話，維持原本預設 `<TEAM_NAME>`，不中斷詢問。

---

## 全局規則：Sprint 欄位

**不論票型，建票時若該票需要 PM 確認（例如：需求待釐清、方向未定、尚未排入規劃），一律不填 `<CUSTOM_FIELD_ID>`（Sprint）。**

Sprint 填入條件（需全部成立）：
- 需求/問題描述清楚，不需再確認
- 已確認要在本 Sprint 處理

若不確定是否需 PM 確認，**在 Step 0 資訊確認時一起詢問**：「這張票是否需要 PM 確認後再排入 Sprint？」

---

## Reference 檔案

| 檔案 | 說明 | 何時讀取 |
|------|------|---------|
| `ticket/references/epic-mapping.md` | Epic Key 完整對照表 + 客服分類對應 | 各票型判斷 Epic 時 |
| `ticket/references/adf-templates.md` | Bug、Task、Story、Sprint Bug 的 ADF JSON 範本 | 各票型撰寫 description 時 |

---

> **共用常數**
> - `projectKey`: `SD`（可被環境變數 `JIRA_PROJECT_KEY` 覆蓋）
> - `team_field_id`: `<CUSTOM_FIELD_ID>`（建票時放在 `additional_fields` 內；值不可預設，每次詢問使用者後才填入，見下方「全局規則：Team 欄位」）
> - `environment_field_id`: `<CUSTOM_FIELD_ID>`，允許值：`Dev` / `Alpha` / `Beta` / `Production`

> **建票工具呼叫注意事項（實測驗證，2026-09-22）**
> - `createJiraIssue` 的必填欄位是 **`issueTypeName`**，不是 `issueType`。各票型檔案內若寫 `issueType:` 一律視為錯誤，改成 `issueTypeName:`。
> - 子票（Subtask）的 `issueTypeName` 統一用 **`Sub-task`**（英文、含連字號），不要用中文「子任務」或無連字號的「Subtask」。
> - `cloudId` 不能直接傳網域字串 `your-team.atlassian.net`，要先呼叫 `getAccessibleAtlassianResources` 取得該站台的 GUID（例：`<NOTION_ID>`），用這組 GUID 當 `cloudId` 參數。
> - 目前 session 可用的 Atlassian MCP 工具前綴是 `mcp__dca1df4c-48f4-482b-a56f-06d7d2e301ae__`（例：`mcp__dca1df4c-48f4-482b-a56f-06d7d2e301ae__createJiraIssue`），不是文件裡舊寫的 `mcp__atlassian__` 或 `mcp__claude_ai_Atlassian__`。此 ID 可能因環境而異，執行前先確認實際可用的工具清單，勿硬編。
> - 取得 Sprint ID：`searchJiraIssuesUsingJql` 回傳的 issue 不含 `<CUSTOM_FIELD_ID>`，需再對該 issue 呼叫 `getJiraIssue` 並指定 `fields: ["<CUSTOM_FIELD_ID>"]` 才能拿到 Sprint 物件（取其中 `id`）。
