---
name: pm-spec
description: "在規格庫寫規格（繁體中文）：寫 spec.md 含 AC 與指標、從草稿產出 User Story 或 Userflow、從程式碼反推現況規格、查某個邏輯寫在哪。Use when 使用者說「寫 spec」「寫規格」「寫 AC」「產 user story」「產 userflow」「從程式碼反推」「這個邏輯寫在哪」。"
argument-hint: "<write|story|flow|reverse|search> [feature 路徑 / 描述]"
---

# pm-spec：寫規格

規格只寫在規格庫，這是唯一來源。

用法：`/pm-spec <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `write` | 把收斂的方向寫成 `spec.md`（Story 敘事模板），含 AC 與指標定義 | `reference/write.md` |
| `story` | 從草稿產出 User Story（Gherkin）到 `stories.md` | `reference/story.md` |
| `flow` | 從草稿產出 Userflow 到 `flows.md` | `reference/flow.md` |
| `reverse` | 從前後端程式碼反推現況規格：要 Story 讀 `reverse-story.md`，要 Userflow 讀 `reverse-flow.md` | `reference/reverse-story.md` |
| `search` | 查某個功能邏輯目前寫在哪些規格（只查已上線的 `specs/`） | `reference/search.md` |

## 沒帶子指令

判斷使用者要哪個子指令；判斷不出來就列出子指令表，只問這一題。
