# pm-spec search

根據使用者描述的功能 / 行為 / 邏輯，快速定位到規格庫中的對應 story 和章節。

> **搜尋範圍只含「現況」**：`specs/`、`userflows/`。
> **一律不搜 `drafts/`**（WIP 草稿）與 `archive/`（歷史封存）——避免把還沒上線的規則當成現況回報。
> 使用者若明確要求「連草稿一起找」「drafts 裡有沒有」，才另外搜 `drafts/`，且結果必須標明 `draft（未上線）`。

## 輸入

使用者透過參數提供功能描述：`$ARGUMENTS`

若參數為空，詢問使用者要查什麼功能。

## 搜尋策略：模組定位 → 雙關鍵字組 + 交集收斂

核心思路：先從模組目錄鎖定範圍，再將描述拆成**兩組獨立關鍵字**，分別搜尋後**取交集**排除噪音。

### Step 0：讀模組目錄，定位可能的模組

先讀 `specs/SPEC-TOC.md`（模組總目錄）；沒有這個檔就 `ls specs/docs/` 列出實際的模組目錄。根據使用者描述判斷最可能落在哪 1-2 個模組。下方的模組對照表是範例，以規格庫實際目錄為準。這能：
- 幫助展開功能定位組的關鍵字（知道模組的中英文名稱和子目錄）
- 在交集結果仍有多個候選時，優先看對應模組的檔案
- 使用者描述模糊時，可以列出可能的模組讓使用者確認

模組對照（快速參考）：

| 使用者可能說的 | 對應模組 |
|---|---|
| 訂單、查詢、退貨、取消 | `01-order-lifecycle` |
| 付款、退款、發票、金流 | `02-payment-and-invoice` |
| 出貨、物流、配送、收件日 | `03-shipment-and-logistics` |
| ERP、匯入、對帳、庫存 | `04-erp-integration` |
| 商品、活動、優惠券、加購、積分 | `05-product-and-marketing` |
| 會員、登入、權限、經銷商 | `06-member-and-auth` |
| 蝦皮、WordPress、經銷商平台 | `07-external-platforms` |
| 通知、稽核、搜尋、站台設定 | `08-infrastructure` |

### Step 1：拆成兩組關鍵字

| 組別 | 抽什麼 | 範例 |
|------|--------|------|
| **A — 功能定位組** | 功能 / 模組名詞，用來鎖定「在講哪個模組」 | `訂單查詢`、`訂單列表`、`order.*query`、`order.*list` |
| **B — 行為特徵組** | 具體規則 / 數值 / 狀態，用來鎖定「什麼邏輯」 | `三個月`、`3個月`、`90天`、`date.*range`、`created_at` |

每組內做同義詞展開（中英文、數字寫法、技術名詞），各自組成一條 grep 正則。

> 查詢只有一個詞（例如「運費」）、拆不出兩組時，只跑單組搜尋，不做交集。

### Step 2：兩組分別廣搜

對以下目錄，**兩組各跑一次** `grep -rln`：

1. **`specs/docs/` 的 story 檔**（`*.feature.md`）— 最精準
2. **`specs/docs/` 的模組主文件**（`_index.md`）— 含前端規則、搜尋邏輯
3. **`specs/docs/` 的 MR 變更紀錄**（排除上面兩類）
4. **`userflows/`** — 使用者情境劇本（此目錄可能不存在，先確認再搜）

```bash
# 功能定位組
grep -rln "PATTERN_A" specs/docs/ --include="*.feature.md"
# 行為特徵組
grep -rln "PATTERN_B" specs/docs/ --include="*.feature.md"
# 兩組結果取交集（同時命中 A 和 B 的檔案）
```

對 `_index.md`、MR 紀錄、`userflows/` 重複同樣的雙組搜尋 + 交集。

### Step 3：交集收斂

- **兩組都命中的檔案**直接列為主要候選（通常只剩 1-3 個）
- **只命中單組的檔案**列為次要候選（補充提及）
- 檔名含功能關鍵字的額外加分（如 `order-query.feature.md`）

為什麼交集有效：同一個詞在不同業務語境意思不同（「三個月」可能是配送日期、對帳週期、CDP 統計區間），但同時也在講「訂單查詢」的檔案通常只有真正相關的那幾個。

### Step 3.5：同模組 `_index.md` Fallback

交集策略在 `_index.md` 上容易漏（因為 `_index.md` 的用詞可能跟 story 不同，導致某一組關鍵字沒命中）。

**規則**：當 Step 3 的 story 檔交集已有命中時，**自動去讀命中 story 所在模組的 `_index.md`**，用 B 組關鍵字做一次 grep，不依賴交集。

```bash
# 例：story 命中了 specs/docs/01-order-lifecycle/order-management/stories/order-query.feature.md
# → 自動用 B 組關鍵字搜同模組的 _index.md
grep -n "PATTERN_B" specs/docs/01-order-lifecycle/order-management/_index.md
```

這確保 story 的「上層規格摘要」（通常在 `_index.md` 裡用一句話帶過）不會因為交集漏掉而缺席。

### Step 4：精確 grep 帶行號 + 上下文驗證

對候選檔（含 Step 3 交集結果 + Step 3.5 fallback 結果）跑 `grep -n` 帶行號，讀命中行前後的完整 Scenario / 章節，最終確認語意吻合。

### Step 5：彙整回覆

對確認相關的檔案，讀取完整 Scenario / 章節內容，按輸出格式回覆。

## 輸出格式

用以下格式回覆：

```
### 查詢結果：{功能描述}

**主要規格**

1. [{story 或章節標題}]({檔案相對路徑}:{行號})
   - 規則摘要（1-2 句）
   - 對應 Scenario：{Scenario 名稱}

2. ...

**補充提及**（非主要但有提到的地方）

- [{檔案}]({路徑}:{行號}) — 一句話說明提到什麼

**待釐清**（如果 story 中有標註 `🟡 待確認`、TBD 或待釐清事項）

- 列出相關的待釐清項目
```

## 注意事項

- **不要搜 `drafts/` / `archive/`**（除非使用者明確要求）。搜尋範圍是現況規格庫，**結果要標明來源類型**（story / _index / MR 紀錄 / userflow）。
- 如果搜不到任何結果，告知使用者並建議：
  1. 換個關鍵字再試
  2. 可能這個功能還沒被規格化（建議去 `drafts/` 開新規格）
- 不要臆測規格沒寫的內容，找到什麼就回報什麼。
