---
name: pm-launch
description: "功能上線後的工作（繁體中文）：給業務、營運、客服看的 release note、把 feature 從 drafts 封存、把程式碼的新行為補進現況規格、專案回顧。Use when 使用者說「寫 release note」「上線公告」「封存 feature」「archive」「規格跟上程式碼」「sync code」「寫 retro」「專案回顧」。"
argument-hint: "<release|archive|sync-code|retro> [feature / 專案]"
---

# pm-launch：上線後

上線之後，讓使用單位知道、讓規格庫保持乾淨、讓團隊留下經驗。

用法：`/pm-launch <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `release` | 給使用單位看的 release note：上了什麼、怎麼用、對我有什麼影響 | `reference/release.md` |
| `archive` | 已上線的 feature 從 `drafts/` 封存到 `archive/<sprint>/`，修好引用並開 PR | `reference/archive.md` |
| `sync-code` | 讀前後端 repo 的新變更，把還沒寫進 `specs/` 的行為補進 stories | `reference/sync-code.md` |
| `retro` | 從群組對話匯出與專案紀錄整理時間軸，收斂成 Keep / Problem / Try | `reference/retro.md` |

## 沒帶子指令

判斷使用者要哪個子指令；判斷不出來就列出子指令表，只問這一題。
