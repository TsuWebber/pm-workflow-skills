# 依 draft spec 產出 User Story（pm-spec story）

## 目的

讀 `drafts/` 裡**指定的規格檔**,把規格內容拆解成以業務價值為維度的 User Story,
每個 Story 附符合 DDD/BDD 規範的 Gherkin 情境,輸出成同 feature 資料夾裡的一份文件。
讓 PM 寫完 spec 後,能立刻拿到一份 PO / RD / QA 都讀得懂的故事清單,作為後續 `pm-ticket spec` 拆票與 QA 測試設計的依據。

## 使用方式

```
pm-spec story [draft_path] [output_path]
```

| 參數 | 必填 | 說明 | 預設 |
|---|---|---|---|
| `[draft_path]` | 否 | 指定 `drafts/` 底下的規格檔（通常是 `drafts/<sprint>/<feature>/spec.md`）；給資料夾就讀其中的 `spec.md` | 未提供則掃 `git status --porcelain drafts/` 取這次變動的 draft;仍找不到或有多個候選 → 列出並詢問 |
| `[output_path]` | 否 | 輸出檔位置 | 見「輸出位置規則」 |

---

## 執行步驟

### 1. 定位來源檔

- 有 `[draft_path]` → 用它;**只認 `drafts/` 底下的檔案**,指到 `specs/`、`userflows/`、`archive/` 一律拒絕並說明原因（現況區與封存區不從這裡產故事）。
- 未提供 → 掃 `git status --porcelain drafts/` 與 `git diff --name-only -- drafts/`,取這次變動的規格檔;
  多個候選或完全沒有 → 列出候選詢問使用者,不要自行猜一個。

### 2. 完整讀取（不是只看 diff）

- **完整讀取**來源檔內容與 frontmatter（`title`、`feature`、`sprint`、`spec_version`）。
- 若來源是 feature 資料夾裡的 `spec.md`,一併讀同層的 `decisions.md` / `actions.md` 補足上下文——
  但**故事內容只依 spec 本身**;decisions 只用來理解背景,actions 裡未定案的項目進「待釐清」。

### 3. 萃取素材（對齊 spec 模板）

spec 已是 Story 結構：**沿用 spec 的 STORY 編號與 User Story，不重拆**。從各章萃取產故事的素材:

| spec 章節 | 用途 |
|---|---|
| Scope（本版 / 後續 / Out） | 故事骨架（本版 STORY 清單都要覆蓋；「後續」「Out」不產故事） |
| Story 與規格 › User Story | 直接成為 US 的 As a / I want / So that |
| Story 與規格 › 功能規則 | 每條規則對應到至少一個 Scenario；含業務動作順序（寫進 Gherkin 時**去 UI 化**）、狀態轉換（合法/非法）、權限/資格、邊界與例外（Unhappy path 素材） |
| Definitions › 共通規則 | 跨 story 的規則，併入各相關 US 的 Scenario |
| Definitions › 名詞 | Ubiquitous Language |
| Story 與規格 › 相關 story | US 之間的銜接 |
| Story 與規格 › AC（`AC-nnnn`） | 每條 AC 對應到至少一個 Scenario |

- 來源檔不是鎖定模板（如自由格式的調研 / 補充文件）→ 就內容中可辨識的「角色、行為、規則、邊界」萃取,缺的章節略過。

### 4. 拆 User Story + 寫 Gherkin

- 以**業務價值**為維度拆故事,每個 Story 用 `As a / I want / So that` 描述。
- Actor 一律用 Business Role（取自各 STORY 的 `As a`,如:客戶、物流人員、客服人員）,禁止 RD/QA/前端/後端。
- 每個 Story 附一段 Gherkin,**必須同時涵蓋 Happy Path 與 Unhappy Path**。
- **標出與現況的關係**:先用 `pm-spec search` 的方法比對 `specs/` 同模組的現況規格；若 spec 指出或比對到該 Story 對應現況已存在的行為（該 STORY 功能規則內指向 `specs/` 現況規格的連結，或寫明「現況 → 本版」差異處）,
  US 標頭加一行 `對齊現況:[<story 名>](../../../specs/docs/<模組>/<capability>/stories/<story>.feature.md)（本次變更:<一句話>）`;全新行為標 `🆕 新增`。
- **對齊現況的 US 要帶原測資**:讀取對應的現況 story（`specs/` 下的 `.feature.md`,唯讀,只取不改）,
  把既有 Scenario / Examples **併入該 US 當 baseline（不標記）**,再疊上本次變更的列（標 `# ← v<版本> 新增/修改`）。
  工程師在同一張 Examples 表就看到「原本的測資 ＋ 這次加的」,不用另開現況檔對照。
  現況檔找不到或對應不明 → US 標 `🟡 待確認：現況對應未明` 並收進「待釐清」,不要硬湊 baseline。
- Gherkin 撰寫**完全遵循 [reverse-story.md](reverse-story.md) 裡的「DDD Gherkin 撰寫規範」「Scenario 判斷矩陣」「Scenario 撰寫風格」**（先讀取該檔再動筆,不要憑印象）。要點:
  - 用業務語言,禁 UI 元件 / UI 操作 / API HTTP / 技術實作詞彙。
  - 一個 Scenario = 一條 Business Rule;同規則多變體用 `Scenario Outline` + `Examples`。
  - 共用前提抽 `Background`;用結果描述,不用過程描述。

### 5. 建 Traceability（可追溯性）

- 產出 Story ↔ spec STORY ↔ AC 對照表:每個 Story 標註對應哪個 `STORY-xxx`、覆蓋了哪些 `AC-nnnn`。
- **沒被任何 Story 覆蓋的 STORY 規則 / AC 要明確列出**,說明原因（如:純技術項、屬 UI 細節、待釐清）——不可默默漏掉。

### 6. 待釐清（不臆測）

- spec 裡的 `🟡 待確認` / `TBD`、actions.md 裡未定案的項目 → 收進輸出檔的「待釐清」章節,**不自行拍板補完情境**。
- 某個 Story 因未定案而寫不出完整 Scenario → Story 保留,Gherkin 處標 `🟡 待確認：規格未明,見待釐清 #n`。

### 7. 輸出檔案

**輸出位置規則**（未指定 `[output_path]` 時）:

- 來源是 `drafts/<sprint>/<feature>/spec.md` → 輸出 `drafts/<sprint>/<feature>/stories.md`。
- 來源是其他檔（如 `drafts/<sprint>/<feature>/phase1-gaps.md`） → 同層輸出 `<原檔名去 .md>.stories.md`。
- 輸出檔已存在 → 先讀舊檔,記下其 `source_spec_version`、US 清單與「Story 異動紀錄」章節,再**就地整份重生**（來源 spec 是唯一真相,stories 是衍生物,不做增量合併）。
- 重生後比對新舊兩版,產出 **Story 異動摘要**（US 與 Scenario 層級,標 `[新增]` / `[修改]` / `[刪除]`）:
  - 追加進輸出檔的「Story 異動紀錄」章節（最新在上;舊紀錄從舊檔原封搬回,不清空）;
  - 同時列在回報結果裡。
  - 這份摘要就是**工程 / QA 要對齊的行為差異清單**——哪些 Scenario / Examples 測資變了,實作與測試就跟著改哪裡。
- **測資層級的變動要標到行**:Examples 新增 / 修改的列,行尾加 Gherkin 註解 `# ← v<新 spec_version> 新增`（或 `修改`）,
  讓工程師從異動紀錄點進 US 後,一眼看到是哪一筆測資。
  行內標記**只保留最近一版**——重生時移除上一輪的舊標記,歷史一律看「Story 異動紀錄」表。

  例（spec 0.3 → 0.4,在既有 Story 加一條測資）:

  ```gherkin
  Examples:
    | 訂單金額 | 配送地區 | 結果   |
    | 1000    | 台灣本島 | 免運   |
    | 1500    | 海外     | 不免運 |  # ← v0.4 新增（AC-0005）
  ```

### 8. 跨 feature 衝突掃描

- 輸出檔寫完後,掃**其他** draft feature 的 stories.md 的「對齊現況」行(例:`grep -rn "對齊現況" drafts/*/*/stories.md`,排除本 feature),
  與本次產出的 US 對齊目標比對:
  - 同一份現況 story 被兩個以上 feature 對齊 → **潛在衝突**,在回報結果列出:
    哪個 feature、本檔哪個 US 對上他們哪個 US、一句話說明在搶同一條什麼規則。
  - 已知限制:對方 feature 還沒跑過 `pm-spec story`(沒有 stories.md)就掃不到;不硬去 parse 對方的 spec.md 猜觸點。
- 衝突**只警示、不阻擋、不改內容**:要不要先對齊由 PM 決定,兩邊的檔案都不要動。

### 9. 詢問是否建票

- 回報結果後,問使用者:「要順便執行 `pm-ticket spec` 依這份草稿建 FE / BE 的 JIRA Story 嗎?」
  - 要 → 委派 `pm-ticket spec`,draft_path 帶本次的來源 spec 路徑(parent key 依 `pm-ticket spec` 自己的流程詢問)。
  - 不要 → 結束,提醒之後可隨時自己跑 `pm-ticket spec`。
- 只詢問一次,不糾纏;重生(非首次產出)且內容只有小幅異動時,可改問「異動要不要同步到已開的 ticket?」並附上異動摘要供貼到 JIRA,不重複開新票。

### 10. 回報結果

```
✅ User Story 產出完成

📄 來源: drafts/<sprint>/<feature>/spec.md（spec_version: <...>）
📝 輸出: drafts/<sprint>/<feature>/stories.md

📖 Story 清單
- US-1: <標題>（對應 STORY-001 / AC-0001, AC-0002）
- US-2: <標題>（對應 STORY-002 / AC-0003）

🔁 Story 異動（spec_version 0.2 → 0.3,重生時才有）
- [修改] US-2: <Scenario 名> 的 Examples 增加 <...>
- [新增] US-5: <標題>
- [刪除] US-3: <標題>（對應 STORY 已從 spec 移除）

⚠️ 未覆蓋項目(如有): STORY-004 某規則（純技術項）
⚠️ 待釐清(如有): {列出 🟡 待確認項目}

⚠️ 潛在衝突(如有):
- 2609/hk-sf-selfpickup 也對齊 specs/docs/03-shipment-and-logistics/.../free-shipping.feature.md
  → 兩邊都在改免運規則,先對一下本檔 US-2 vs 他們的 US-4
```

---

## 輸出檔模板

````markdown
---
title: <功能顯示名> — User Stories
feature: <feature-slug，同 spec frontmatter>
sprint: <sprint>
source: ./spec.md
source_spec_version: <產出當下 spec.md 的 spec_version>
generated_by: pm-spec story
---

# <功能顯示名> — User Stories

> 本檔由 [spec.md](./spec.md)（spec_version <x.y>）衍生;spec 更新後請重跑 `pm-spec story` 重生,不要手改兩邊。
> Ubiquitous Language:<列出本功能用到的 Domain Terms,取自 spec Definitions「名詞」>

## US-1: <標題>

**As a** <業務角色>
**I want** <想達成的事>
**So that** <業務價值>

覆蓋:STORY-001 / AC-0001, AC-0002
對齊現況:<story 名>（`<規格庫>/specs/docs/<模組>/<capability>/stories/<story>.feature.md`）（本次變更:<一句話>）｜或 🆕 新增

```gherkin
Feature: <功能>
  Background:
    Given <共用業務前提>

  # Happy Path
  Scenario: <成功情境>
    Given ...
    When ...
    Then ...

  # Unhappy Path
  Scenario: <失敗/邊界情境>
    Given ...
    When ...
    Then ...
```

## US-2: <標題>
...

## Traceability

| Story | 對應 spec STORY | 覆蓋 AC |
|---|---|---|
| US-1 | STORY-001 | AC-0001, AC-0002 |

**未覆蓋**:<STORY-x 規則 / AC-x — 原因>（無則寫「（無）」）

## Story 異動紀錄

> 每次重生追加一列,最新在上。這是給工程 / QA 的**行為差異清單**:spec 改版後,要對齊的就是這裡列的 Scenario / 測資變動。首次產出寫「（初版）」。

| 日期 | spec_version | 異動 |
|---|---|---|
| <YYYY-MM-DD> | 0.2 → 0.3 | [修改] US-2:<Scenario 名> Examples 增加 <...>;[新增] US-5 |
| <YYYY-MM-DD> | 0.2 | （初版） |

## 待釐清

- <TBD 項目,指回 [actions.md](./actions.md) 對應條目>（無則寫「（無）」）
````

---

## 撰寫規則

- 繁體中文;技術名詞（欄位名、狀態 enum、API path）保留英文。
- **提到檔案就要能點得開**:一律用相對 markdown 連結並指到具體檔案(含 `.md`)——同 feature 資料夾 `[spec.md](./spec.md)`,跨區域從 `drafts/<sprint>/<feature>/` 退三層 `[order-management](../../../specs/docs/01-order-lifecycle/order-management/_index.md)`。不要用 `[[...]]` wiki 連結。
- 內容只依 draft **規格本身**;spec 沒寫清楚的不臆測,進「待釐清」。

## 定位與分工（常見疑問）

- **會不會寫進 `specs/`?** 不會。輸出永遠在 `drafts/<sprint>/<feature>/`;`specs/` 是現況區（後端規則由 oms 同步,改了會被下次同步覆蓋）。feature 上線後整個資料夾由 `pm-launch archive` 封存,stories.md 跟著資料夾走。
- **PM 改了 spec 怎麼辦?** spec.md 是唯一真相:PM 照原流程改 spec（changelog（`<規格庫>/drafts/_meta/TEMPLATE-changelog.md`） 落一筆 + `spec_version` +0.1）→ 重跑 `pm-spec story`。stories.md 整份重生,「Story 異動紀錄」會留下這次哪些 US / Scenario 變了;`source_spec_version` 落後於 spec.md 的 `spec_version` 就代表 stories 過期該重跑。
- **工程師拿什麼實作?** 三層分工:
  - `spec.md` — 技術權威(欄位、API、狀態機、流程),實作細節看這裡;
  - `pm-ticket spec` 產的 JIRA Story — 工作項與驗收條件,排程與指派看這裡;
  - `stories.md` — **行為驗收契約**:spec 改版後,「Story 異動紀錄」列出的 Scenario / Examples 測資變動,就是工程與 QA 要跟著調整的行為清單。

## 注意事項

- 來源一律是 `drafts/`;不從 `specs/`、`userflows/` 等現況區或 `archive/` 封存區產故事。
- 本指令**只產文件**:不建 JIRA 票（那是 `pm-ticket spec`）、不從程式碼反推（那是 `pm-spec reverse`）、不改 spec.md 本身。
- **不要**執行任何 `git commit` / `git push`;要送審用 `pm-ship` 或 `pm-ship（開 PR 步驟）`。
- stories.md 是衍生物,不寫進 changelog.md（changelog 只記 spec 本身的異動）。
