# daily：Daily 回報

## Overview

把「Notion Task 資料庫裡當天 `Do Date` 的工作事項」+「Google Calendar 當天的會議/工作時間塊」整合成一份 Daily 報告草稿,格式相容於 DingTalk 純文字貼上(不能用 markdown 粗體/斜體/checkbox 語法,會跑掉)。

輸出語言:繁體中文。輸出位置:對話框,先給草稿確認,使用者明確要求才寫入 Notion。

## When To Use

- 使用者說「幫我寫 Daily」「產生今天的日報」「寫 XX 天的 Daily」
- 使用者要看「今天/某天要做什麼」,需要合併 Task 資料庫 + Calendar 的資訊

不適用:單純想查 Task 資料庫或 Calendar 內容而不需要輸出成 Daily 格式,直接查就好,不用套這個 skill。

## Data Sources

- **Notion Task 資料庫**:data source id `<NOTION_ID>`(使用者 頁面下,原生 database id `<NOTION_ID>`)
  - 用 `Do Date` 屬性篩選目標日期(注意:存的是 UTC,查詢/顯示時要轉換成 GMT+8 / Asia/Taipei)
  - `Product` 屬性做分組(沒有 Product 值的歸「Others」)
  - `Status` 屬性:目前觀察到的值有 `backlog`(未完成)/ `Complete`(完成)/ `Abandon`(**有做但沒做完**,不是「放棄不列入」的意思——`Abandon` 一樣要列進報告,勾選狀態比照未完成顯示 ☐)。這個欄位選項名稱使用者可能會再改,**每次查詢時先看實際回傳值,不要假設固定字串**
  - 全部任務的查詢視圖:`https://www.notion.so/<PAGE_ID>?v=<NOTION_ID>`(無篩選,查回來自己依 Do Date 篩選目標日期)
- **Google Calendar**:主帳號 ``,用 `list_events` 查目標日期 00:00–24:00,`timeZone: Asia/Taipei`
- **Reviews 資料庫**(寫回用,僅使用者確認後才寫):data source id `<NOTION_ID>`,屬性 `Type`(選 `Daily`)、`Date`、`Name`

## Date Logic

- 目標日期(「今天工作事項」的日期)可以是使用者指定的任何一天,預設是實際的今天
- 「昨天」= 目標日期往前推**最近一個工作日**,不是單純減一天
  - 例:目標日期是週一 → 昨天是上週五,不是週日
  - 例:目標日期是週三 → 昨天就是週二

## Calendar Classification Rules

先排除以下事件(名稱模糊比對,不分大小寫/前後空格),這些是每天固定的站會,完全不寫進報告:
- `Daily Squad – Team A`
- `Daily Squad – Team B`
- `Daily Squad – tech Team`

剩下的事件依 `colorId` 分類:
- **🔵 會議**:`colorId` 是空值(預設色)或除了下面兩種以外的任何值 —— 不管有沒有其他與會人,**一律照顏色判斷,不要用「有沒有與會人」當依據**(這條規則使用者明確糾正過)
- **🟢 工作事項**:`colorId = "10"`(Basil 綠色)—— 併入對應 Product 分類下的工作事項,規則同 Task 資料庫的項目(不押時間、同名合併)
- **🟣 其他事項(紫色,colorId = "3")**:**目前規則是完全不寫進報告,整筆略過**(使用者明確說「紫色的都不要寫上來」)

全天事件(例如請假通知、OOO)不是使用者自己的會議,略過不寫。

## Output Format(純文字,不能用 markdown 粗體/斜體/checkbox)

因為要貼進 DingTalk,markdown 語法會被破壞,所以:
- 區塊標題用全形方括號:`【📆 昨天】`、`【🎯 今天工作事項】`
- Product / 會議 子分類用全形引號:`「Product 名稱」`、`「會議」`
- 勾選狀態用純文字符號,不是 markdown checkbox:`☑`(完成)/ `☐`(未完成)
- 不要用 `**粗體**`、`*斜體*`,不要用 `- [ ]` 語法
- 不要輸出「⚠️ 注意事項」或任何提醒/衝突偵測區塊(使用者明確說不需要)

### 固定結構

```
📤 Daily|YYYY-MM-DD(週X)

【📆 昨天】

「Product A」
☑/☐ 項目名稱

「Others」
☑/☐ 項目名稱

「會議」
☑/☐ HH:MM–HH:MM 會議名稱

【🎯 今天工作事項】

「Product A」
☑/☐ 項目名稱

「Others」
☑/☐ 項目名稱

「會議」
☑/☐ HH:MM–HH:MM 會議名稱
```

規則:
1. **工作事項**(來自 Task 資料庫的項目,或 Calendar 綠色事件)一律**不押時間**,同名項目合併成一筆
2. **會議**(Calendar 藍色/預設色事件,排除三個固定站會)**要押時間**,格式 `HH:MM–HH:MM`
3. 紫色事件完全不出現
4. Product 分類直接用 Task 資料庫的 `Product` 欄位值,順序不用刻意排序,有值就開一個「」子區塊
5. 每個大區塊(昨天/今天)裡,Product 分類都排在前面,「會議」子區塊放最後
6. 「今天工作事項」除了目標日期 `Do Date` 到期的項目,也要把還在 Backlog(沒有 `Do Date`、`Status` 未完成)的項目一併列入對應 Product(通常是「Others」),當作延續事項,不用特別加註「延續」字樣,直接混在該 Product 分類的清單裡
7. 在每個 Product 子區塊內,有 `Do Date`(已壓時間)的項目排在前面,沒有 `Do Date`(還沒壓時間的 backlog 延續項目)排在該子區塊最下面。昨天、今天兩個大區塊都套用這個排序規則
8. 若目標日期還沒發生(例如幫下週一先產草稿),「昨天」區塊的內容基於**當下查詢時的最新狀態**,並在標題後面加一行提醒文字(純文字,不是注意事項區塊那種正式提醒,是簡短一句話)例如:「(當下還沒結束,以下是目前已知狀態)」

## Workflow

1. 確認目標日期(沒說就是今天),推算出「昨天」= 最近一個工作日
2. 查 Notion Task 資料庫全部任務,篩出:
   - `Do Date` = 目標日期的項目
   - `Do Date` = 昨天日期的項目
   - 沒有 `Do Date` 但 `Status` 未完成的項目(算 Backlog 延續,併入今天工作事項)
3. 查 Google Calendar 目標日期 + 昨天兩天的事件,套用 Calendar Classification Rules
4. 依 Product 整理成固定結構,輸出純文字草稿到對話框
5. 等使用者確認/調整,**不要主動寫入 Notion**
6. 只有使用者明確說「寫進 Notion」/「寫進 Reviews」才寫入 Reviews 資料庫:
   - `Name`: `YYYY-MM-DD Daily`
   - `Type`: `Daily`
   - `Date`: 目標日期
   - 內容:最終確認版的純文字草稿

## Notes

- 這些規則是跟使用者在對話中一步步確認出來的個人偏好,如果使用者之後又提出新的調整(例如又要改回押時間、又要加回其他事項),**以使用者最新的話為準**,並視情況更新這個 SKILL.md
- Task 資料庫的 `Status` 選項名稱之前從 `Pending`/`Not started`/`Done` 變成 `backlog`/`Complete`,代表使用者會自己在 Notion UI 調整欄位,每次執行都要先查實際 schema,不要硬記舊值
