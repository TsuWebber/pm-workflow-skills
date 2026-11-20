# wrap：送審後收尾

## 步驟

對象是 `$ARGUMENTS` 指定的 feature 資料夾（沒給就用這次變更的 feature）。逐項問，不要自動全做；使用者說「不用」就跳過。每項先給草稿，寫檔或送出前等使用者確認。

1. **changelog**：寫在 feature 資料夾的 `changelog.md`（不存在就建立），一行一筆：`- YYYY-MM-DD 改了什麼（影響哪個 STORY / AC）`；大改補，小修可略
2. **推 PR**（spec repo）：走 `pm-ship`；推前確認目標 PR 還開著
3. **Notion**：spec repo 為主，只有使用者明確要求才單向輸出（先列要更新什麼給他看）
4. **群組同步文字**：pm-config 指定的溝通工具（沒指定就用純文字），純文字 bullet、結論先講、不用 markdown 表格
   - 給業務：不分前後端，講影響和他們要做什麼
   - 給設計師：bullet 列 UI 要調整的點
   - 給工程師：結論＋SPEC 位置（附中文章節名）
5. **Jira**：**先問 team／assignee／sprint／priority 再填**；Story 指派給 PM 自己、Subtask 給工程師，人力未定先不指派；Story vs Subtask 類型要開對
6. **Release note、mockup** 是否需要同步更新
