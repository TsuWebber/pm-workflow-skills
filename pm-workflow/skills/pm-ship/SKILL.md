---
name: pm-ship
description: "規格送審與收尾（繁體中文）：分組 commit、push、開 PR；審 PR 時留行內建議、收到建議後套用；送審後補 changelog 與群組同步文字；定案的規格輸出成 Notion 展示頁。Use when 使用者說「ship」「送審」「開 PR」「commit」「幫我留 PR 建議」「套用 PR 建議」「收尾」「同步群組」「輸出到 Notion」。"
argument-hint: "<suggest|apply|wrap|notion> [PR 編號 / feature 路徑]（不帶子指令＝ship）"
---

# pm-ship：送審

規格寫完、自查過後，送出去讓團隊審。

用法：`/pm-ship <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `（不帶）` | 分析變更、開分支、分組 commit、push、開 PR；commit 細節見 `auto-commit.md`、`commit.md`，開 PR 見 `pr.md` | `reference/ship.md` |
| `suggest` | 審別人的 PR 時，把改寫建議用 suggestion 留在指定行 | `reference/suggest.md` |
| `apply` | 讀出 PR 上別人留的 suggestion，核對後套用到本地分支 | `reference/apply.md` |
| `wrap` | 送審後收尾：changelog、推 PR、Notion 輸出、群組同步文字、開票提醒 | `reference/wrap.md` |
| `notion` | 把定案的規格輸出成可看版本的 Notion 展示頁（單向） | `reference/notion.md` |

## 沒帶子指令

直接執行 `reference/ship.md`。
