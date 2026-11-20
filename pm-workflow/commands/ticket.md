---
name: ticket
description: |
  依 drafts/ 的規格草稿變動,把內容拆成前端(FE)與後端(BE)兩種 User Story,分別在 JIRA 建立 ticket。
  來源是 draft spec(不是 code diff);一份草稿可能只產 BE、只產 FE,或兩者都產。
  關鍵字:ticket, 建票, JIRA, user story, FE, BE, draft
---

# 依 draft spec 建立 FE / BE User Story（JIRA）

## 目的

讀 `drafts/` 裡**這次變動的規格草稿**,依內容拆解成前端與後端各自的 User Story,分別在 JIRA 建立 ticket。
讓一份 PM 草稿能自動落成 FE / BE 兩條可獨立開發、獨立驗收的工作項。

## 使用方式

```
/ticket [parent_key] [draft_path]
```

| 參數 | 必填 | 說明 | 預設 |
|---|---|---|---|
| `[parent_key]` | 否 | 要掛的 Epic / Story key(例:`SD-xxxxx`) | 未提供則取草稿 frontmatter 的 `refs.jira_epic`;仍無則詢問;再無 → 建為獨立 Story 並互相 link |
| `[draft_path]` | 否 | 指定草稿檔 | 未提供則取當前變更中的 `drafts/*.md` |

---

## 執行步驟

### 1. 前置檢查

- 確認 Atlassian MCP 可用(`atlassianUserInfo`);不可用 → 提示 `/mcp` 授權後停止。
- 找出目標草稿:
  - 有 `[draft_path]` → 用它。
  - 否則掃 `git status --porcelain drafts/` + `git diff -- drafts/`,取這次變動的 `drafts/<sprint>/*.md`。
  - **只認 `drafts/`**;若沒有 draft 變更 → 告知並停止(這條指令的來源是草稿,不是任意 code diff)。

### 2. 讀懂草稿（不是只看 diff）

- **完整讀取**變動的草稿檔內容與 frontmatter(`title`、`sprint`),理解整個功能,而不是只讀 diff 幾行。
- 若草稿仍有 `TBD` / 「待釐清」未定案 → 記下來,建票時寫進「待確認」,並在輸出提醒 spec 尚未定案。

### 3. 依內容拆 FE / BE

依草稿內容判斷要產哪幾種 Story(可能只有一種):

- **BE(後端)**:API endpoint、資料欄位 / 型別 / 驗證、業務規則與計算、狀態流轉、背景 Job、對外整合。
- **FE(前端)**:頁面 / 表單 / 彈窗(Dialog)、互動與導頁、畫面狀態(loading / empty / error)、欄位呈現與前端驗證。

> 判斷原則:草稿只描述計算 / 規則 → 只開 BE;只描述畫面 / 互動 → 只開 FE;兩者都有 → 各開一張。

### 4. 為每個 discipline 建立 User Story

用 `createJiraIssue` 建立,每個 discipline 一張:

- **Project**:`SD`
- **Issue Type**:`Story`(User Story)
- **Parent**:`[parent_key]`(若有且階層允許);否則建為獨立 Story
- **Summary**:`[BE] <功能名>` / `[FE] <功能名>`
- **Labels**:`backend` 或 `frontend`,並加上 sprint 標籤(例:`sprint2606`)
- **Assignee**:預設不指定(FE / BE 常是不同人),需要再手動指派
- **Description**:用下方對應模板

#### User Story 描述模板

```markdown
## User Story
作為 <角色>,我想要 <目標>,以便 <效益>。

## 範圍（依 draft 內容)
### {子功能 1}
- {這個 discipline 要做的具體項目}
### {子功能 2}
- ...

## 驗收條件(AC)
- [ ] AC1: <可獨立驗證的條件>
- [ ] AC2: ...

## 待確認(如 draft 仍未定案)
- {TBD / 待釐清項目}

## 來源規格
- draft: `drafts/<sprint>/<slug>.md`
```

- **BE 模板**偏重:API 合約、資料欄位、業務規則、狀態流轉。
- **FE 模板**偏重:頁面 / 彈窗、互動流程、畫面狀態、欄位呈現與前端驗證。

### 5. 建立關聯

- FE 與 BE 兩張互相 link(關係用 `relates to`)。
- 兩張都在描述「來源規格」指回同一份 draft 檔路徑。

### 6. 輸出結果

```
✅ 依 draft 建立 User Story 完成

📄 來源草稿: drafts/<sprint>/<slug>.md

🎫 建立的 ticket
- [BE] <title> — <key> — <url>
- [FE] <title> — <key> — <url>
- Parent: <parent_key 或「獨立 Story,已互相 link」>

⚠️ 尚有未定案項目(如有):
- {列出 TBD / 待釐清}
```

---

## 撰寫規則

- Ticket 描述繁體中文,技術名詞(API path、欄位名、狀態 enum)保留英文。
- 內容只依 draft **規格本身**;draft 沒寫清楚的不臆測,寫進「待確認」。
- User Story 的 AC 要能獨立驗證,對齊 draft 的驗收 / 情境段落。

## 注意事項

- 來源一律是 `drafts/` 的草稿;不從 `specs/`、`frontend/` 等現況區或任意 code diff 產票。
- Parent 不確定就**詢問**,不要硬套某個 key。
- **不要**執行任何 `git commit` / `git push`;本指令只建 JIRA ticket。
- Atlassian MCP 未認證 → 提示 OAuth 授權;建立失敗 → 顯示錯誤並建議檢查 `/mcp`。
