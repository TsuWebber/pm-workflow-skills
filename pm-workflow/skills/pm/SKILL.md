---
name: pm
description: "軟體 PM 工作流（繁體中文）。涵蓋決策文件、release note、Jira 開票（Bug / Sprint Bug / Task / 簡道雲 / 需求票），以及任何文件的審查（review）、補強（harden / impact）、精簡與用語統一。寫規格（方向收斂、spec、AC）不在這裡，交給團隊的規格工具。Use when the user types /pm, or asks to 寫決策文件、寫 release note、開 Jira 票、檢查 / 審查文件、補邊界情境、盤點跨部門影響。"
argument-hint: "<init|decide|release|ticket|review|harden|impact|distill|clarify> [對象：規格檔路徑 / Notion URL / 檔案 / 描述]"
---

# PM

協助 PM 把產品需求從零散資訊推進到可交付的文件與工單。
一個 skill，多個子指令：`/pm <指令> [對象]`。每個指令的完整做法放在 `reference/<指令>.md`，用到才讀。

## 原則

1. **把事情做完。** 交付物要能直接用；資訊不足就用 `🟡 待確認：` 標在原處，不留白、不含糊帶過。
2. **讀者決定寫法。** 先判斷這份東西給誰看（見 Modes），再決定語氣、結構與細節深度。
3. **不替使用者做決定、不擴寫範圍。** 只整理已討論的內容；做了假設就標出來。
4. **先給草稿，再動外部系統。** Notion / Jira / Confluence 寫入一律等使用者明確指示。
5. **交付前自檢。** 產出 PRD、AC、決策文件前，用 `reference/review/rules.md` 的規則快速掃過一次，有 P0 問題先修再給。

## Setup（每次執行都要做）

1. **讀專案背景**：找目前工作目錄下的 `.pm/PROJECT.md`。
   - 有 → 讀取，作為產品線、系統、使用單位、相關部門、baseline、連結的依據。
   - 沒有 → 照常執行，但不要捏造專案背景；在回覆結尾用一句話建議執行 `/pm init`。
2. **讀共用底線**：讀 `reference/pm-floor.md`。所有指令都適用，與指令檔衝突時以指令檔的明確規定為準。
3. **讀指令檔**：讀 `reference/<指令>.md` 並照著執行。
4. 公司專有名詞（系統代號、通路、產品線）與部門職責以全域 `CLAUDE.md` 為準。

## Modes

Mode 由「這份產出給誰看」決定，不是由專案決定。

| Mode | 讀者 | 寫法 | 指令 |
|---|---|---|---|
| Build | 設計、工程、QA | 結構固定、可驗證、零討論語氣 | `ticket` |
| Decide | 主管、跨部門 | 選項並列比較、明確給建議、留決策紀錄 | `decide` `impact` |
| Announce | 使用單位（業務、營運、客服） | 使用者視角、講結果不講系統、步驟口語 | `release` |

審查類指令（`review` `harden` `distill` `clarify`）依被審文件本身的 Mode 判斷標準。

## Commands

| 分類 | 指令 | 用途 | 檔案 |
|---|---|---|---|
| Setup | `init` | 建立 / 更新專案背景 `.pm/PROJECT.md` | `reference/init.md` |
| Build | `decide` | 單次重大改動的決策文件（.md） | `reference/decide.md` |
| | `release` | 給使用單位看的 release note | `reference/release.md` |
| | `ticket` | 建立 Jira 工單（Bug / Task / Story / Epic…） | `reference/ticket.md` |
| Evaluate | `review` | 一次跑完規則檢查與讀者審查，合併成依嚴重度排序的問題清單（規則檢查＋讀者審查） | `reference/review.md` |
| Refine | `harden` | 補邊界、例外、逆向流程、跨系統影響 | `reference/harden.md` |
| | `impact` | 盤點對各部門的影響、要誰配合、誰拍板 | `reference/impact.md` |
| | `distill` | 壓縮冗長內容，不刪決策與規則 | `reference/distill.md` |
| | `clarify` | 統一用語、消除模糊詞 | `reference/clarify.md` |

### 寫規格不在本 skill

規格只有一個來源：團隊用 Git 管理的規格庫（spec repo）。方向收斂、寫 spec 與 AC、規格預審、依規格拆前後端票，都交給規格庫自己的工具。

本 skill 負責規格以外的事，並且可以直接審規格檔：`review`、`harden`、`impact`、`distill`、`clarify` 都能讀 `spec.md`。

### Routing

- **沒帶指令（只打 `/pm`）**：不執行任何產出。讀 `.pm/PROJECT.md`（若有）與對話脈絡，判斷目前在哪個階段，列出建議的下一步 1–3 個指令，每個附一句理由。
- **明確指令**：讀對應的 reference 檔並執行。
- **自然語言描述**：對應到最接近的指令後執行，並在開頭用一句話說明用了哪個指令（例：「用 `impact` 盤點跨部門影響」）。要寫規格就請使用者改用規格庫的工具。無法判斷時問使用者，只問這一題。
- **指令不存在**：列出指令表，不自行發明新流程。

### 典型流程

```
init →（decide）→【規格庫：寫規格】→ review / harden / impact →【規格庫：預審 → 送審】→ ticket → release
```

不需每步都走；依使用者當下進度挑。完成一個指令後，依此流程主動建議下一步（一句話，不主動執行）。
