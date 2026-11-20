---
name: pm-report
description: "PM 的例行回報（繁體中文）：每天早上整理昨天在 Notion、Jira、規格庫的改動與群組結論並依專案產出群組訊息、Daily 工作回報、個人週報。Use when 使用者說「整理昨天的改動」「寫給群組的更新」「寫 Daily」「寫週報」「weekly recap」，或由每日排程觸發。"
argument-hint: "<digest|daily|weekly> [日期 / 週會筆記 URL]"
---

# pm-report：每天・每週

不屬於單一需求、跟著時間跑的工作。

用法：`/pm-report <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `digest` | 整理昨天的改動與群組結論，依專案拆成多段群組訊息（適合排程每天早上跑） | `reference/digest.md` |
| `daily` | 從任務資料庫與行事曆產生 Daily 回報 | `reference/daily.md` |
| `weekly` | 從週會筆記、行事曆、任務資料庫產生週報（結果版＋個人紀錄版） | `reference/weekly.md` |

## 沒帶子指令

判斷使用者要哪個子指令；判斷不出來就列出子指令表，只問這一題。
