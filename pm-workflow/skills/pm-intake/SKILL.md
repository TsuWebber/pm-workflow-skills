---
name: pm-intake
description: "把外部素材收進規格庫（繁體中文）：Notion 上的規格搬進 drafts（含圖片搬到 Google Drive）、會議記錄轉成決策與待辦、零散規劃素材整理進流程。Use when 使用者說「從 Notion 搬進來」「整理會議記錄」「會議轉待辦」「這些素材幫我整理」「圖片搬到 Drive」。"
argument-hint: "<notion|meeting|material> [Notion URL / 會議記錄 / 檔案]"
---

# pm-intake：收素材

動筆寫規格前，先把散在各處的東西收進規格庫。

用法：`/pm-intake <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `notion` | Notion 規格搬進 drafts，分成規格、決策、待辦、會議、範圍外五類；圖片依 `reference/notion-images.md` 搬到 Drive 並換成連結 | `reference/notion.md` |
| `meeting` | 會議記錄整理成決策、待辦與規格增補提案，更新 `decisions.md`、`actions.md` | `reference/meeting.md` |
| `material` | 還沒成形的素材（domain model、story mapping、草稿）整理進規劃流程 | `reference/material.md` |

## 沒帶子指令

判斷使用者要哪個子指令；判斷不出來就列出子指令表，只問這一題。
