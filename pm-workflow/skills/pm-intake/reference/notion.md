# From Notion（把 Notion 規格搬進 drafts）

## 定位

PM 目前多在 Notion 寫規格。這個 skill 是**搬遷匝道**：把一份已寫好的 Notion 文件，
搬進 `drafts/<sprint>/<feature>/` 開始版本化、可 review、永不過時。

它是 `pm-plan scope` 的**姊妹入口** —— 兩者終點相同（建骨架 → 交棒 `pm-spec write`），差在起點：

| 入口 | 起點 | 做什麼 |
|---|---|---|
| `pm-plan scope` | 冷啟動（只有一個想法） | 引導思考 → 建骨架 |
| **`pm-intake notion`** | **已有 Notion 成品** | **抓取 + 分類 → 建骨架** |

**這個 skill 不做的事**：
- 不做需求探索 / 方向討論（那是 `pm-plan scope`）。
- 不寫完整 `spec.md` 內文、不填 12 節（那是 `pm-spec write`）—— 本 skill 只把「規格素材」整理好交棒。
- 不挑刺（那是 `pm-review qa`）。
- **不回寫 Notion**：Notion 是唯讀來源，只往 spec repo 寫。

預設語言：繁體中文（技術名詞、欄位名、狀態 enum、API path 保留英文）。

---

## When To Use

適用：
- PM 手上有**一份 Notion 規格**，要搬進 spec repo 管理
- 「把這份 Notion 搬進來」「從 Notion 匯入」「這份 Notion 變成 draft」
- 直接貼一個 `notion.so` 連結說「搬進來」

不適用（改用別的）：
- 只有想法、還沒寫 → `pm-plan scope`
- 資料夾已存在、方向已清楚、要寫 / 改 spec → `pm-spec write`
- 已有 spec、只想挑問題 → `pm-review qa`
- 搬的是**會議記錄**（不是規格）→ `pm-intake meeting`（它也吃 Notion 連結）

> **一份 Notion = 一個 feature**。若這份 Notion 塞了多個功能，先請 PM 說「這次只搬哪一個」，其餘另跑一次。

---

## Step 0：token 成本確認（先估、先跟 PM 確認）

> **開跑前必做，不可略過。** 這個 skill 會**讀整份 Notion + 分類 + 建骨架 + 交棒 pm-spec write**，是**高 token 消耗**操作，動輒是一般問答的數倍。務必先讓 PM 知道成本、確認要跑再開始。

1. **先粗估規模**（不必精準，給 PM 一個量級感）：
   - 看來源大小 —— Notion 頁有多長（幾段 / 幾個區塊 / 有無大表格）。
   - 給一句白話估算，例如：「這份 Notion 蠻長的，搬進來大概會用掉**不少** token（含分類與交棒寫 spec）」。
2. **明確請 PM 確認**：一句話說明「這一步比較燒 token，要我現在開始嗎？」等 PM 回「好 / 開始 / 確認」再進 Step 1。
3. PM 若想省：建議**一次搬完、別反覆重跑**；一份 Notion 只搬一個 feature（多功能請先切分）。
4. 已在同一輪對話明確說過「直接跑 / 別再問」→ 可不重複確認，但**仍要一句提示成本**。

---

## Step 1：拿到來源

兩種輸入，擇一：

1. **Notion 連結**（優先）—— 用 **Notion MCP 讀**（`notion-fetch`；找不到頁面用 `notion-search` 先定位）。
   - 需 PM 的 Claude 已連上 **Notion 連接器**。連不上 / 讀不到 → 轉方案 2。
2. **貼上內容** —— PM 直接把 Notion 內容整段貼進來。

把來源連結記下來，稍後寫進 `spec.md` frontmatter 的 `refs.notion`（保留供查證）。

---

## Step 2：判類型、定 sprint 與 slug

1. **判類型**（沿用 `pm-plan scope` Step 0）：這是**新功能**還是**優化 / 改既有**？
   - 優化：稍後分類時特別留意「改動命中既有邏輯 / 限制」的段落，多半是 `actions.md` 的待釐清。
2. **問 sprint 與 slug**：「這個放哪個 sprint？」（如 `2607`）、給 feature 一個英文 slug（如 `product-master`）。
3. 用**使用者提供的當天日期**（不自行捏造）作為 changelog / meetings 檔名的日期。

---

## Step 3：自動分類（一次分完，再一次審）

把整份 Notion 內容**一次自動切成五桶**，不逐段打斷 PM：

| 桶 | 收什麼 | 落到哪 |
|---|---|---|
| **規格** | 要做什麼、業務規則、欄位 / 列舉、操作流程、狀態、權限、AC 素材 | 暫存 → Step 5 交棒 `pm-spec write` |
| **決策理由** | 為什麼這樣定、取捨、考慮過 / 被否決的選項 | `decisions.md`（`D-1`、`D-2`…） |
| **待辦 / 待釐清** | TBD、open question、跨部門待確認、矛盾、缺漏 | `actions.md`（🔴 / 🟠 / ⚪ 分級） |
| **會議 / 討論** | 討論串、逐字對話、帶時間戳的紀錄 | `meetings/<日期>-notion匯入.md`（原樣保留） |
| **範圍外** | 跟這個 feature 無關、屬別的功能 | **不寫入**，在 Step 6 列出來問 PM |

分類原則：
- **未定案的不臆測** → 一律進 `actions.md`，不塞進規格桶。
- **矛盾不擅自拍板** → 進 `actions.md` 並在待釐清清單點名。
- 看不懂 / 判不準歸屬的段落 → 先標記，進待釐清清單問 PM，不硬塞。

---

## Step 4：建 feature 資料夾骨架

在 `drafts/<sprint>/<feature-slug>/` 建立（從 `drafts/_meta/TEMPLATE-*.md` 複製）：

1. **`spec.md`** —— 只填 frontmatter（`title` / `feature` / `sprint` / `discipline` / `owners` / `refs.notion` 填來源連結）+ 12 節骨架留白。**內文交給 `pm-spec write`**。
2. **`decisions.md`** —— 寫入「決策理由」桶（含一則 `D-1` 記「初版搬遷自 Notion，來源見 refs」）。
3. **`actions.md`** —— 寫入「待辦 / 待釐清」桶，🔴 / 🟠 / ⚪ 分級。
4. **`meetings/`** —— 有討論桶內容才建 `<日期>-notion匯入.md`，原樣保留。
5. **`changelog.md`** —— 記一筆：`<日期> · sprint <x> · spec_version 0.1` — `[新增] 初版骨架搬遷自 Notion（pm-intake notion）`。

> 資料夾 / 檔案建立**不需 PM 碰 git**；之後送出用 `pm-ship`。

---

## Step 4.5：圖片落地（來源有圖就必跑）

Notion 規格幾乎都有圖，而本 repo **圖片一律不進版控**（`CLAUDE.md`）。
來源只要有圖，**在這裡交棒 `pm-intake notion（圖片搬到 Drive）`**：下載 → 上傳 PM 指定的 Google Drive 資料夾 → markdown 只留 `[標題](Drive URL)`。

- Notion 的圖是 **signed URL、約 1 小時過期** → 抓完頁面就儘早跑，別拖到 spec 寫完。
- 不在本 skill 重造上傳邏輯；失敗的圖由 `pm-intake notion（圖片搬到 Drive）` 自己寫進 `actions.md`。
- **一張圖都不准默默丟掉**——搬不成的要留痕，不是當作沒看到。

---

## Step 5：交棒 pm-spec write 寫 spec.md

把整理好的**規格桶**交給 `pm-spec write`（整份撰寫模式）填滿 `spec.md` 12 節。
**不在本 skill 重造 12 節撰寫邏輯** —— pm-spec write 會處理鎖定模板、AC、指標確認、changelog + spec_version。

> 銜接方式：完成 Step 4 後，提示「接著用 `pm-spec write` 把規格桶寫成完整 spec.md」，或直接續跑 pm-spec write 的整份撰寫流程，把規格桶當輸入。

---

## Step 6：一次審 + 待釐清清單

自動分完、骨架建好後，**一次性**交給 PM 校正（不逐段打斷）：

1. **分類對照表** —— 「這份 Notion 的各段，我分別判給了哪個桶」，讓 PM 掃一眼抓分錯的。
2. **範圍外清單** —— 「這幾段我判為範圍外 / 屬別的 feature，對嗎？」
3. **待釐清清單**（最重要，對齊 `PM-SOP`）—— 分類時抓到的矛盾、缺漏、判不準的段落，逐項請 PM 確認或補上。清單越短代表原 Notion 越清楚。

PM 校正後，套用修正（搬錯桶的移位、補上的內容歸位）。

---

## Step 7：收尾與銜接

1. 一句話摘要：搬了哪個 feature、分成幾桶、待釐清剩幾項。
2. 提示下一步：
   - spec.md 尚未寫 → **`pm-spec write` 寫完整規格**（若 Step 5 未續跑）。
   - 寫完想挑問題 → **`pm-review qa`**。
   - 送出 / 開 PR → **`pm-ship`**（git 交給它）。
3. 規格不用 status 欄位（在不在審看 Gitea PR、上線與否看資料夾位置）；draft 存活期間**不搬資料夾**（搬家會讓相對連結的層數失效）。
   - **沒有「送審中」狀態**——送審期間仍是 `draft`，送審與否看 Gitea 上有沒有開著的 PR。
   - **上線叫 `released` 不叫 `shipped`**——`pm-ship` 只是開 PR 送審，別把兩者搞混。

---

## Writing Rules

- 一律繁體中文，用產品語言，不過度工程化。
- 分類**不臆測**：未定案進 `actions.md`、「為什麼」進 `decisions.md`、討論進 `meetings/`；規格桶只放已定案素材。
- 矛盾 / 判不準的**一律點名進待釐清清單**，不自行拍板、不硬塞規格。
- 跨檔引用一律用相對 markdown 連結，指到具體檔案（含 `.md`）；從 `drafts/<sprint>/<feature>/` 引用現況規格要退三層（例 `[order-management](../../../specs/docs/01-order-lifecycle/order-management/_index.md)`）。不要用 `[[...]]` wiki 連結。
- **不回寫 Notion**；`refs.notion` 保留來源連結供查證。
- 日期用使用者提供的當天日期，不自行捏造。
