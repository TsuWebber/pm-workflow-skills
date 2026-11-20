---
name: pm-setup
description: "PM 工作流的準備工作（繁體中文）：建立專案背景 .pm/PROJECT.md、安裝並授權規格庫需要的工具、把規格庫更新到最新。Use when 使用者說「建立專案背景」「pm init」「裝工具」「設定環境」「sync 規格庫」「拉最新規格」。"
argument-hint: "<init|tools|sync> [對象]"
---

# pm-setup：準備

開新專案、第一次使用、或每天開工前做的事。

用法：`/pm-setup <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `init` | 建立或更新專案背景 `.pm/PROJECT.md`，之後每個 skill 都會讀 | `reference/init.md` |
| `tools` | 一次裝好 git、Git 平台憑證、tea、rclone 等工具並完成授權；`reference/doctor.sh` 做健康檢查 | `reference/tools.md` |
| `sync` | 把本機規格庫安全更新到最新，進行中的草稿不會弄丟 | `reference/sync.md` |

## 沒帶子指令

判斷使用者要哪個子指令；判斷不出來就列出子指令表，只問這一題。
