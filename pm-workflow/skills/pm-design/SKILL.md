---
name: pm-design
description: "PM 與設計師對齊規格（繁體中文）：設計師的修改記成 DR 條目並和 PM 討論、接受後才改規格；做可在瀏覽器操作的互動 prototype 驗證流程。Use when 使用者說「設計師改了」「記 DR」「design review」「做 prototype」「畫面流程跑一次」。"
argument-hint: "<dr|prototype> [feature 路徑 / 設計修改內容]"
---

# pm-design：設計對齊

規格和畫面兩邊都在動的時候用。

用法：`/pm-design <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `dr` | 設計師的修改記成 `design-review.md` 的 DR 條目，討論後接受的才產出規格增補提案，交給 `pm-spec write` | `reference/dr.md` |
| `prototype` | 為 drafts 的 feature 做可在瀏覽器操作的 prototype，也能挑可用性與一致性問題 | `reference/prototype.md` |

沒有 PM 確認的 DR 一律不改 `spec.md`。

## 沒帶子指令

判斷使用者要哪個子指令；判斷不出來就列出子指令表，只問這一題。
