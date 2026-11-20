# 設計審閱 → 回覆 + spec 增補提案

## 這個 skill 在做什麼

設計師的修改量多、要逐條討論、結果有三種（接受 / 不採納 / 還在談）。
本 skill 把來回記在 `drafts/<sprint>/<feature>design-review.md`，並在 PM 定案時掃描 `spec.md`，
提出增補提案。

**核心紀律：**
- 未經 PM 確認不改 `spec.md`。套用時**委派 `pm-spec write`**，changelog 與 `spec_version` 由它落，本 skill 不自己改 spec。
- **只有 ✅ 接受的條目才會碰 spec。** 🟡 討論中不動規格，避免未定案內容流進權威檔。
- 回覆與改 spec 是兩個動作：PM 可以只回覆、不改 spec，條目就停在 🟡。

## 使用方式

```
pm-design dr [feature 路徑或名稱] [DR 編號 | 來源]
```

| 用法 | 做什麼 |
|---|---|
| `pm-design dr <feature> <貼上的修改內容>` | **收件**：把設計師的修改拆成 DR 條目 |
| `pm-design dr <feature> DR-3` | **處理單條**：讀條目 + 掃 spec，與 PM 對話回覆 |
| `pm-design dr <feature> 掃描` | **整批分類**：把所有 🆕 / 🟡 條目分三類給 PM |

無法判斷 feature → 詢問使用者要歸到哪個 `drafts/<sprint>/<feature>/`。

## 執行步驟

### 0. 確保檔案存在

`design-review.md` 不存在 → 複製 `drafts/_meta/TEMPLATE-design-review.md` 建立。

### 1. 收件（輸入是設計師的原始修改）

來源可能是貼上的文字、Figma 留言、PR 留言。

- **一條修改一個 DR**：一則訊息含多個要求就拆開。
- 編號接續檔內最大的 DR 編號，不重用。
- 每條填：提出人 / 日期、關聯 Story（對照 spec.md 判斷，沒把握就留 `TBD`）、修改內容（改前 → 改後）、理由。
- 設計師沒講理由 → 理由欄寫 `TBD（設計師未說明）`，並在整批輸出裡列為「需向設計師補資料」，附一句建議要問的話。
- 圖片不進 repo；只留 Figma / Drive 連結。
- 更新索引表。

### 2. 整批分類（`掃描`，或收件後一併做）

讀 `spec.md`、`decisions.md`、`actions.md`，把 🆕 / 🟡 條目分三類給 PM：

- **可直接接受**：只動單一處、不影響其他 Story、與既有決策不衝突。
- **需要討論**：牽涉取捨、跨 Story、或與 spec / decisions 衝突（寫出衝突點與兩邊說法）。
- **需向設計師補資料**：理由或畫面不清，附要問的話。

### 3. 處理單條（對話）

1. 用幾句話說明：設計師要改什麼、受影響的 Story / AC / 欄位。
2. **掃 spec**，找出：
   - 直接對應的 Story、AC。
   - 其他 Story 是否引用同一欄位 / 規則（避免改 A 漏 B）。
   - 是否與 `decisions.md` 已定案的決策抵觸。
3. PM 口述回覆 → 寫進該條「討論」，標人名與日期（人名用 PM 自己的名字，不要寫「PM」以外的臆測）。
4. PM 說定案 → 產出**spec 增補提案**（不寫檔）：

```markdown
## Spec 增補提案（DR-3，給 PM 審，通過才套進 spec.md）

- [修改] §5 5.2 列表預設維持列表式，新增切換卡片的按鈕（來源：DR-3）
- [新增] STORY-003 · AC-0005 切換後偏好需記住（來源：DR-3）
```

5. 與現有決策抵觸 → 不自行消解，寫進 `actions.md` 標 🔴，列衝突點交 PM 拍板。

### 4. 套用（PM 確認後）

- PM 確認提案（全選 / 挑選 / 不套）。
- 套用 → **委派 `pm-spec write`** 改 `spec.md`（changelog、`spec_version` 由它處理）。
- 回填該條 DR：
  - 狀態改 ✅ 或 ❌。
  - 「結論」寫一句理由。
  - 「spec 異動」填 `spec_version` 並連 `changelog.md`。
  - 有取捨 → 補 `decisions.md` 一則 `D-n`，DR 條目連過去。
- 更新索引表。
- 有套用任何提案時，問 PM 是否重跑 `pm-spec story`（沿用 `pm-intake meeting` 的做法）。

## 撰寫規則

- 繁體中文；技術名詞（欄位名、狀態 enum）保留英文。
- 提到檔案一律寫相對 markdown 連結，不用 `[[...]]`。
- **只根據設計師的原話與 spec**，不臆測；講不清楚的 → `TBD`，需要追的進 `actions.md`。
- 結論要標來源（DR 編號），可回溯。

## 不要做

- 不要未經 PM 確認就改 `spec.md`；套用一律委派 `pm-spec write`。
- 不要因為「看起來合理」就把 🟡 條目改成 ✅；狀態由 PM 定案。
- 不要刪除 ❌ 條目；保留當歷史。
- 不要把圖片放進 repo。
- 不要自行消解與 `decisions.md` 的矛盾。
