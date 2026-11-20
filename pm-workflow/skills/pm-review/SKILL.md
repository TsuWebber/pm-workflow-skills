---
name: pm-review
description: "審查與補強任何規格或文件（繁體中文）：QA 角度挑問題、規則檢查加讀者審查、補邊界與逆向流程、盤點跨部門影響、全文掃矛盾、統一用語與精簡，以及送審前用 QA 標準在獨立 context 完整預審。Use when 使用者說「審一下」「挑問題」「review」「補邊界」「還漏了什麼」「對哪些部門有影響」「掃矛盾」「用語統一」「精簡」「送審前檢查」「QA 會退回什麼」。"
argument-hint: "<qa|readers|edge|impact|consistency|polish|preflight|all> [spec.md / 檔案 / Notion URL]"
---

# pm-review：補強・審查・自查

從寫完規格到送審前，所有「找問題、補內容」的事都在這裡。

用法：`/pm-review <子指令> [對象]`

## 每次執行先做

照共用底線 `../../shared/floor.md`（本 skill 資料夾往上兩層）的「0. 每次執行先做」：讀 `~/.claude/pm-config.md`、讀 `.pm/PROJECT.md`、再讀下面對應的子指令檔。`$ARGUMENTS` 是子指令後面的內容。

## 子指令

| 子指令 | 做什麼 | 檔案 |
|---|---|---|
| `qa` | QA 角度：缺漏、模糊、衝突、容易做錯、做太多 | `reference/qa.md` |
| `readers` | 規則檢查（P0 / P1 / P2）＋工程、QA、設計、營運、財務的讀者審查，合併成一份清單 | `reference/readers.md` |
| `edge` | 補狀態轉換、取消與退貨等逆向流程、權限、資料異常、0 筆與上限 | `reference/edge.md` |
| `impact` | 盤點各部門受到的影響、要準備什麼、誰拍板 | `reference/impact.md` |
| `consistency` | 全文掃矛盾：規則衝突、AC 與內文不一致、公式邊界、狀態流轉 | `reference/consistency.md` |
| `polish` | 先 `polish-clarify.md` 統一用語、消除模糊詞，再 `polish-distill.md` 精簡；使用者只要其中一個就只跑那個 | `reference/polish-clarify.md` |
| `preflight` | 送審前用 QA 的標準完整預審，只列問題不改檔 | `reference/preflight.md` |

### preflight 要在獨立 context 跑

`preflight` 刻意看不到前面的對話，避免作者的說明影響審查。用 Agent 工具開一個 subagent 執行：prompt 寫明 `reference/preflight.md` 的完整路徑、規格庫路徑、要審的 feature 路徑，其他對話內容一律不帶。subagent 只讀不寫，結果回報給使用者。

### all

依序跑 `qa` → `readers` → `edge` → `impact` → `consistency`，最後合併成一份依嚴重度排序的清單（同一件事只列一次）。不含 `polish` 與 `preflight`。

## 沒帶子指令

依文件目前的狀態建議：剛寫完 → `qa` 或 `all`；要送審 → `preflight`；文字太長或用語亂 → `polish`。列出建議後只問這一題。
