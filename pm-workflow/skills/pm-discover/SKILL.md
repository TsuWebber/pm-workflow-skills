---
name: pm-discover
description: "規格動筆前的調研（繁體中文）：掃解法案例（別人怎麼做、誰做不好）、收痛點的實例證據。Use when 使用者說「別人怎麼做」「找案例」「競品做法」「這個痛是真的嗎」「收集痛點證據」。"
argument-hint: "<cases|pains> [feature 或痛點描述]"
---

# pm-discover：調研

選用。需求還沒想清楚、或要說服別人「這個痛是真的」時才用。共用原則見 `../../shared/principles.md`、`../../shared/skill-contract.md`。

用法：`/pm-discover <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `cases` | 從成品慣例、做不好的案例等面向收集解法空間，產出 `cases/` | `reference/cases.md` |
| `pains` | 把痛點落成可追溯的實例證據，產出 `pains/` | `reference/pains.md` |

兩個都跑完後，在 feature 資料夾寫一份 `FINDINGS.md` 綜合結論，交棒給 `pm-plan scope`。

## 沒帶子指令

判斷使用者要哪個子指令；判斷不出來就列出子指令表，只問這一題。
