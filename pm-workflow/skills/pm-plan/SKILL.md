---
name: pm-plan
description: "決定要不要做與往哪個方向做（繁體中文）：引導對話收斂範圍並建好 drafts 資料夾、重大改動寫決策文件給主管或跨部門拍板。Use when 使用者說「要不要做」「範圍到哪」「先想清楚」「開新 feature」「寫決策文件」「要主管拍板」「比較幾個方案」。"
argument-hint: "<scope|decide> [需求描述 / 檔案]"
---

# pm-plan：定方向

動筆寫規格前的最後一步。

用法：`/pm-plan <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `scope` | 引導對話想清楚要不要做、解什麼問題、碰哪些模組、範圍到哪，並建好 `drafts/<sprint>/<feature>/` | `reference/scope.md` |
| `decide` | 單次重大改動的決策文件：背景、選項比較、建議 | `reference/decide.md` |

## 沒帶子指令

判斷使用者要哪個子指令；判斷不出來就列出子指令表，只問這一題。
