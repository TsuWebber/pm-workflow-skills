---
name: spec-revise
description: SPEC 修改後的「掃矛盾」與「收尾」流程（繁體中文）。掃矛盾：全文檢查規則衝突、AC 與內文不一致、公式邊界、狀態流轉、適用範圍。收尾：changelog、推 PR、Notion 輸出、DingTalk 群組同步文字、Jira 開票、release note／mockup。Use when the user says「掃一下有沒有矛盾」「整份 spec 看一下」「AC 有沒有誤」「改完了 收尾」「幫我同步群組」「改動要補 spec log」，或一輪 SPEC 大改落檔之後。修改 SPEC 本身的規則（GO 才落檔、只寫結論、不推論、回報位置）在全域 collaboration.md，不在這裡。
---

# spec-revise：掃矛盾＋收尾

修改 SPEC 的行為規則見全域 `collaboration.md`〈修改 SPEC〉，本 skill 只管落檔之後的兩件事。

## A. 掃矛盾

大改落檔後主動提議；使用者說「掃一下」時執行。

1. 讀整份 SPEC（spec repo：含 drafts 與尚未合併的 PR）
2. 逐項檢查：
   - 前後規則衝突（增補的段落 vs 原段落）
   - AC 與內文不一致；AC 編號是否連續
   - 公式：是否完整、邊界條件（> vs ≥、含不含 0）
   - 狀態流轉：哪些狀態可取消／可編輯，前後說法是否一致
   - 適用範圍：銷售 vs 銷退、彈窗 vs 詳情、月結 vs 非月結、2C vs 2B
   - 名詞：同一概念是否出現兩種叫法
   - 編號引用：是否都附中文名、指向的章節是否存在
3. 輸出清單（不改檔）：

```
[章節（中文名）]
- 問題：……
- 建議：……
- 嚴重度：🔴 會做錯／🟡 措辭
```

4. 有需要決定的，用選擇題問；使用者說 GO 才修

## B. 收尾

逐項問，不要自動全做；使用者說「不用」就跳過。

1. **changelog／SPEC LOG**：大改補；小修可略
2. **推 PR**（spec repo）：走 `/ship`；推前確認目標 PR 還開著
3. **Notion**：spec repo 為主，只有使用者明確要求才單向輸出（先列要更新什麼給他看）
4. **群組同步文字**：DingTalk 純文字 bullet、結論先講、不用 markdown 表格
   - 給業務：不分前後端，講影響和他們要做什麼
   - 給設計師：bullet 列 UI 要調整的點
   - 給工程師：結論＋SPEC 位置（附中文章節名）
5. **Jira**：**先問 team／assignee／sprint／priority 再填**；Story 給 使用者、Subtask 給工程師，人力未定先不指派；Story vs Subtask 類型要開對
6. **Release note、mockup** 是否需要同步更新
