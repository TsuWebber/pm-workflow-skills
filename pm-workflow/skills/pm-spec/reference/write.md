# Spec Write（寫 / 改規格）

## 定位

把 `pm-plan scope` 收斂好的方向（或已討論完的需求），寫成 `drafts/<sprint>/<feature>/spec.md` ——
spec repo 的 **鎖定 spec 模板**（Story 敘事）、工程師拿來 plan 的單一權威規格。含驗收條件（AC）與指標定義。

**兩種模式**：整份撰寫（骨架 → 填滿）／局部更新（改某節、對齊新 UI）。
**功能含算法 / 數字 / 門檻**時，寫規格前先走「指標確認」。

**這個 skill 不做需求探索 / 方向討論**（那是 `pm-plan scope`），也不挑刺（那是 `pm-review qa`）。
它把**已定案**的內容寫進 spec，未定案的一律轉 `actions.md`。

預設語言：繁體中文（欄位名、狀態 enum、API path 保留英文）。

---

## When To Use

適用：
- `pm-plan scope` 已建好資料夾骨架、方向清楚，要寫成完整 `spec.md`
- 要改 `spec.md` 某一節、對齊新的 UI / 設計、補細節
- 要補驗收條件（AC）
- 功能有算法 / 門檻要定義或調整

不適用（改用別的）：
- 還在想方向、要不要做 → `pm-plan scope`
- 已有 spec、只想挑問題 → `pm-review qa`
- 會議記錄要整理成決策 + 待辦 + spec 增補提案 → `pm-intake meeting`

---

## 前置：找到 feature、載入現況

1. **定位資料夾** `drafts/<sprint>/<feature>/`。
   - 沒有 → 提示「先用 `pm-plan scope` 建骨架」，或當場照 `drafts/_meta/TEMPLATE-*` 補建。
2. **讀四檔**：`spec.md`（現況）、`decisions.md`（已定案結論的來源）、`actions.md`（未定案 —— **這些不准寫進 spec**）、`changelog.md`（改過什麼）。
3. **對照鎖定模板** [TEMPLATE-spec.md](../../../drafts/_meta/TEMPLATE-spec.md) 的章節結構（Background & Goal → Success Metrics → Scope → Definitions → Story 與規格 → Jira / Release Note → 待確認事項）—— 章節順序固定，不得新增 / 刪除 / 重排，某章無內容寫 `（無）`。

> 若來源是 Notion 大文件（搬遷情境）：把它按性質拆進各檔 —— 規格進 `spec.md`、為什麼進 `decisions.md`、待辦進 `actions.md`、會議進 `meetings/`。**只寫進 spec repo，不回寫 Notion。**

---

## 模式判斷（先說理解再動手）

判斷這次是哪種，先一句話說明理解（例：「我理解你要重寫 STORY-003 的建立流程，只動這一個 story」），確認再做：

| 模式 | 觸發 | 範圍 |
|---|---|---|
| **整份撰寫** | pm-plan scope 剛建好骨架 / 全新需求 | 把模板各章從骨架填滿 |
| **局部更新** | 指定某章 / 某 STORY / 某條規則、「改一下」「補」「對齊新 UI」 | 只動指定處，其他不碰 |

---

## 指標確認（功能含算法 / 數字 / 門檻時，寫規格前先過）

**觸發詞**：算法、計算邏輯、抽成、比率、門檻、幾個月、幾 %、判斷「達標 / 活躍 / 新 / 舊」、兩數取高 / 低、時間窗口（過去 3 個月、18 個月內）。

**新指標走三關**：
- **第一關 可算性**：「資料從哪來？」有明確來源（DB table / Excel 欄位 / API）→ 繼續；「應該有 / 不確定」→ 標 🟡 進 `actions.md`，待 RD 確認才鎖定；沒這資料 → 談替代或移除。
- **第二關 驗算**：「門檻值怎麼決定的？」有資料源可拉就算；沒有就給驗算引導（去哪查 / 算什麼公式 / 看什麼判斷合理範圍 / 拿數字回來我幫你判斷）。
- **第三關 邊界**：主動問「A、B 同時成立怎麼算？」「資料缺失（null）怎麼處理？」「有沒有例外不適用？」每個 edge case 都要在定義裡標處理方式。

**調整既有指標**：只重跑改動相關的那一關，不重跑已確認的 ——
門檻改→第二關；公式改→第二 + 三關；資料源換→第一 + 二關；新增指標→第一→二→三關；補邊界→第三關。
改前先問「這指標有沒有被別的功能 / 算法引用？」有 → 列出引用點一起確認。

**指標輸出位置**：
- **簡單**（1–2 指標、算法簡單、只這功能用）→ 寫進 `spec.md`：公式 / 門檻當可驗證規則進對應 STORY 的**功能規則**（跨 story 共用的進 Definitions「共通規則」）、名詞與資料來源進 Definitions「名詞」、edge case 進該 STORY 的 AC。
- **複雜**（3+ 指標、需驗算、或跨功能共用）→ 在 feature 資料夾建 **`metrics.md`**（每指標一個 `M-01…`，含定義 / 公式 / 資料來源 / 時間範圍 / 排除條件 / 門檻 / 驗算依據 / 🟡待確認），`spec.md` Definitions「共通規則」用相對連結 `[metrics.md](./metrics.md)` 引用它。

---

## 撰寫 spec.md（鎖定 spec 模板）

**寫作紀律**（模板的核心規則）：
- 只寫「系統要做什麼」。**不寫為什麼**（→ `decisions.md`）、**不寫討論過程 / 會議**（→ `meetings/`）、**不堆 TBD**（→ `actions.md`）。
- 未定案的不臆測。資訊不足可做**最小合理假設**但明確標記，並把該待確認轉一筆進 `actions.md`；不要在 spec 留 TBD 段落堆積。
- 繁體中文；技術名詞保留英文。跨檔引用用相對 markdown 連結，指到具體檔案（含 `.md`）——同 feature 資料夾 `[decisions.md](./decisions.md)`，跨區域從 `drafts/<sprint>/<feature>/` 退三層 `[order-management](../../../specs/docs/01-order-lifecycle/order-management/_index.md)`。不要用 `[[...]]` wiki 連結。

**各章怎麼填**（對照 `TEMPLATE-spec.md`）：

| 章 | 填什麼 |
|---|---|
| frontmatter | `title` / `feature` / `sprint` / `spec_version` / `owners` / `refs`（figma、design_prototype、decisions、actions、changelog；`design_prototype` 可填外部連結或 HTML 檔相對路徑，沒有就留空） |
| Background & Goal | 🌝 Background：現況痛點一句話（詳細為什麼在 `decisions.md`）＋ 🎯 Goal：一句話 |
| Success Metrics | 可衡量條件，編號 |
| Scope | **本版**（依功能分組歸類：分組名＋一句話「解決什麼」，底下列「STORY-xxx 名稱：一句話」；分組與下方「功能分組」表一致）／**後續**／**Out**（明確不涵蓋，指向別處用相對連結；無則「（無）」） |
| Definitions | **名詞**表（同概念只用一個名字，附白話定義 + 英文 / 程式對應；通用系統名詞已在 `index.md` 者不重複）＋ **共通規則**（跨多條 story 都成立的規則，一句話一條）；**指標資料來源放這** |
| Story 與規格 | 先「功能分組」表（欄位：分組｜解決什麼｜涵蓋 story，story 寫「編號＋名稱」不可只寫編號），再每組每個 STORY：User Story（As a / I want / So that）→ 功能概述 → 功能規則（範疇起訖 + 規則；含欄位 / 列舉 / 狀態轉換 / 角色權限 / 邊界例外，**指標 edge case 放這**）→ 相關 story → `<details>` 內 AC |
| Jira / Release Note | 票與 Release Note 連結，沒有寫「尚未撰寫」 |
| 待確認事項 | 只放指向 `actions.md` 的一句話清單，不展開 |

**功能規則的寫法**：
- 一條規則一行，白話、可驗證；範疇先寫「開始於…；結束於…；不包含的部分指向哪個 story / 規格」。
- 規則多（4 條以上）時用**粗體 topic label + 冒號描述句**分組。
- 涵蓋邊界情境（空狀態、無資料、聯動為空、數值為負 / 零）；能一句話說清就不展開。
- 有「為什麼」的規則在句尾連到 `decisions.md` 的 `D-x`，不在這裡解釋。
- **不用 emoji 當分類 label**（模板固定的 🌝 🎯 除外）。

---

## AC 撰寫（各 STORY 的 `<details>` 驗收條件）

編號 `STORY-xxx · AC-nnnn`，每個 STORY 內連續遞增；格式固定，方便日後接 `pm-ticket spec`：

- **共通前提**：跨情境都成立的前提寫在 `<details>` 開頭一行，避免每條 AC 重複。
- **分兩段**：「要看畫面才驗得出來（N 條）」「看資料就驗得出來（N 條）」；N 要和實際條數一致。
- **每條 AC**：`**STORY-xxx · AC-nnnn** — [標籤] 白話描述` ＋ Given / When / Then。標籤用固定的**九標籤**；手上沒有該清單就問 PM，不自創標籤。
- **數量看複雜度**：簡單（單一主線、無分支）2 條；中等（1–2 條件分支或有例外 / 空狀態）3–4 條；複雜（3+ 分支、多角色 / 跨系統、權限隔離）不設上限。
- **覆蓋順序**：① Happy path（必寫）② 每個獨立條件分支各一條 ③ 最高優先的邊界 / 例外（上限值、空狀態、異常處理）。
- **`actions.md` 裡還沒定案（open question）的項目 → 跳過不寫 AC**，在該 STORY 的 `<details>` 內標「⚠️ 待確認，AC 待補」。
- `When` 單一觸發動作；`Then` 寫可觀察、可驗證的結果，**不寫實作細節**（API 欄位、DB 欄位）；每條聚焦一個驗證點。

格式：
```
**STORY-001 · AC-0001** — [標籤] 可驗證的情境標題
- Given: 前提條件
- When: 使用者操作
- Then: 可觀察、可驗證的結果
```

> AC 對齊 `pm-ticket spec` 產出的 User Story AC —— 寫清楚這裡，拆票時 QA 直接可用。

---

## 局部更新流程（模式 B）

1. **逐節診斷**：比對「現有 spec」vs「新 UI / 新資訊」，每節標 ✅ 已對齊 / 🟡 需補充 / 🔴 需重寫。輸出診斷摘要，只處理 🟡🔴，不動 ✅。
2. **逐節重寫**：一次一節，每節結尾給 `✅ 確認｜改 繼續討論｜跳過`。確認才進下一節。
3. **整合**：輸出更新摘要（已確認 / 已跳過 / 待決定），套進 `spec.md`。

---

## 落地（每次寫 / 改都要做）

1. **改 `spec.md` 對應節**，每條動作標記別：`[新增]` / `[修改]` / `[刪除]`。
2. **`changelog.md` 補一筆**：`<日期> · sprint <x> · spec_version <新版號>`，列改了哪節，並註明 **BE / FE / QA 各要注意什麼**。日期用當天實際日期，不自行捏造。
3. **frontmatter `spec_version` +0.1**，和 changelog 對得起來。
4. **有「為什麼」的定案** → 補一則 `decisions.md` `D-x`（背景 / 選項 / 決定 / 理由 / 來源）；**仍未定案** → 寫進 `actions.md`（🔴 / 🟠 / ⚪ 分級），不留在 spec。
5. 全程**不需 PM 碰 git**。

---

## 收尾與銜接

1. 摘要這次寫 / 改了哪些節。
2. 提示下一步：
   - **挑問題** → `pm-review qa`
   - **拆票開發** → `pm-ticket spec`（依 `spec.md` 拆 FE / BE User Story 建 Jira）
   - **送出 / 開 PR** → `pm-ship`（git 交給它）
3. 規格不用 status 欄位（在不在審看 Gitea PR、上線與否看資料夾位置）；draft 存活期間**不搬資料夾**（搬家會讓相對連結的層數失效）。
   - **沒有「送審中」狀態**——送審期間仍是 `draft`，送審與否看 Gitea 上有沒有開著的 PR。
   - **上線叫 `released` 不叫 `shipped`**——`pm-ship` 只是開 PR 送審，別把兩者搞混。

---

## Writing Rules

- 一律繁體中文，用產品語言，不過度工程化。
- 能一句話說清就不展開成一段；優先描述結果與呈現，不描述系統內部流程。
- 不保留討論語氣；spec 只放結論。
- 資訊不足做最小合理假設並標記，不擴寫使用者沒提到的功能 / 規則。
- 跨檔引用一律用相對 markdown 連結（不要用 `[[...]]`）；不自動寫 Notion。
