---
name: pm-ticket
description: "建立 Jira 工單（繁體中文）：依規格草稿拆前端與後端 User Story；或開 Bug、Sprint Bug、Task、優化、需求、技術、表單通報等票。Use when 使用者說「開票」「建票」「開 Jira」「拆 FE BE 票」「報 bug」「開 task」。"
argument-hint: "<spec|bug|sprint-bug|task|optimization|story|tech|form> [描述 / 規格路徑]"
---

# pm-ticket：開票

依規格拆的開發票走 `spec`；開發與測試期間的 bug、任務、優化走其他票型。

用法：`/pm-ticket <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `spec` | 把規格草稿拆成前端（FE）與後端（BE）兩種 User Story | `reference/spec.md` |
| `bug / sprint-bug / task / optimization / story / tech / form` | 其他票型：先讀 `types.md` 判斷情境，再讀 `ticket/` 底下對應的票型檔 | `reference/types.md` |

開票前先列出要建的票，使用者確認後才建。

## 沒帶子指令

依描述判斷票型：附規格路徑 → `spec`；描述功能異常 → 先問「是不是 Sprint 測試期間發現的」，是 → `sprint-bug`、否 → `bug`；其他情況照 `reference/types.md` 的判斷表。無法判斷就問這一題。
