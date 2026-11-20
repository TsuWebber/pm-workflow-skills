# 會議記錄 → 決策 + 待辦 + spec 增補提案

## 這個 skill 在做什麼

PM 開完會，最花時間的是把一長串討論消化成「要改的 spec、要追的事、拍板的決定」。
本 skill 讀會議記錄 + 對應 feature 的 `spec.md`，一次產出三類結果，PM 只需審核，不必從頭抄。

**核心紀律：未經 PM 確認不改 `spec.md`。** spec 是權威檔,任何增補都先以「提案」形式列出;
PM 在對話中逐條（或帶 `--apply` 全部）確認後,才委派 `pm-spec write` 套用——changelog 與 `spec_version` 由 `pm-spec write` 自動落,本 skill 不自己動筆改 spec。

## 使用方式

```
pm-intake meeting [會議記錄來源] [--apply]
```

| 參數 | 必填 | 說明 | 預設 |
|---|---|---|---|
| `[會議記錄來源]` | 否 | 貼上文字、meetings/*.md 路徑、或 Notion 連結 | 未提供則詢問 |
| `[--apply]` | 否 | 提案產出後跳過逐條詢問,全部套用(仍會顯示套了哪些) | 預設逐條詢問 |

## 輸入

擇一：
- 直接貼上的會議記錄文字
- `drafts/<sprint>/<feature>/meetings/<日期>-<主題>.md`
- Notion 會議頁連結（用 Notion MCP 讀）

若無法判斷對應哪個 feature → 詢問使用者要歸到哪個 `drafts/<sprint>/<feature>/`。

## 執行步驟

### 1. 讀懂脈絡

- 讀會議記錄全文。
- 讀對應 feature 的 `spec.md`（理解現況規格）、`actions.md`（已知待辦，避免重複）、`decisions.md`（已定案，避免衝突）。

### 2. 萃取三類

逐條掃會議記錄，把每個要點歸到其中一類（歸不了的略過，不要硬湊）：

- **決策（已拍板）** → 追加到 `decisions.md`，一則一個 `D-n`，補背景 / 選項 / 決定 / 理由 / 影響 spec 哪節。
- **待辦 / open question（還沒答案）** → 追加到 `actions.md`，分級 🔴 BLOCK / 🟠 次高 / ⚪ 低風險，標類型（待 PM / 待後端 / 待 QA / 待外部）與來源日期。
- **對 spec 的增補** → 產出**提案**（見下），標 `[新增]` / `[修改]` / `[刪除]` 並對到 spec 節次；**不寫進 spec.md**。

### 3. 偵測矛盾

- 會議結論若和現有 `spec.md` / `decisions.md` 抵觸 → 不要自行消解，寫進 `actions.md` 標 🔴，列出「衝突點 + 兩邊說法」交 PM 拍板。

### 4. 產出

1. **更新 `decisions.md` / `actions.md`**（實際寫檔）。
2. **spec 增補提案**（輸出給使用者，不寫檔）：

```markdown
## Spec 增補提案（給 PM 審，通過才套進 spec.md）

- [新增] §5 5.3 商品類型 新增「賣場商品」一列（來源：會議 2026-06-04）
- [修改] §4 BR-2 門檻由 1000 改為 1500（來源：D-6）
- [刪除] §3 3.3 移除「以前有→現在沒有」的第 2 條（來源：會議）

> 套用後請 PM：改 spec.md → 在 changelog.md 補一筆 → spec_version +0.1
```

3. 也附一份可直接貼進 `changelog.md` 的草稿（僅供 PM 不套用、想日後手動處理時參考）。

### 5. 詢問套用（新）

- 列完提案後問 PM:「要套用哪幾條?」——可全選 / 挑選 / 都不要;帶 `--apply` 則跳過詢問全部套用。
- PM 確認後,**委派 `pm-spec write`** 逐條套進 spec.md:
  - changelog.md 落筆與 `spec_version` +0.1 由 `pm-spec write` 的既有邏輯處理,本 skill 不重複寫。
  - 只套 PM 點頭的條目;沒選的保留在提案輸出裡,PM 日後可再處理。
- 都不套 → 到此結束,提案與 changelog 草稿留給 PM。

### 6. 詢問重生 stories（新）

- 有套用任何提案時,問 PM:「要重跑 `pm-spec story` 重生 stories.md 嗎?」
- 同意 → 委派 `pm-spec story`,其「Story 異動紀錄」會列出本輪變了哪些 Scenario / 測資,給工程 / QA 對齊。
- 該 feature 還沒有 stories.md → 改問「要不要順便產第一版?」。

## 撰寫規則

- 繁體中文；技術名詞（欄位名、狀態 enum）保留英文。
- **只根據會議記錄與 spec**，不臆測；記錄沒講清楚的 → 進 `actions.md` 當待釐清。
- 決策 / 待辦要標**來源**（會議日期），可回溯。

## 不要做

- 不要未經 PM 確認就改 `spec.md`（一律先提案）;套用時**委派 `pm-spec write`**,不要自己動筆改 spec / changelog。
- `--apply` 只免去逐條詢問,不免去「回報套了哪些」;套用結果要完整列出。
- 不要自行消解矛盾（交 PM）。
- 不要把「還沒拍板」的討論寫成 `decisions.md`（那是 actions.md 的事）。
