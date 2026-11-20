# To Planning(把規劃中素材歸類進 drafts/planning/)

## 定位

`drafts/planning/` 是 PM **正在規劃、還沒排進 sprint 開發**的 delivery 素材收集地,依
README.md（`<規格庫>/drafts/planning/README.md`） 分成 to-c / to-process / to-r / platform 四條產品線。
這個 skill 是它的**收件與分類站**:PM 丟一份素材進來,判斷歸哪條產品線、哪個 feature 資料夾,
原樣落地,**不改寫內容、不套固定模板**。

跟其他搬遷類 skill 的分工:

| skill | 起點 | 終點 |
|---|---|---|
| **`pm-intake material`** | **規劃階段素材,格式不定,還沒排 sprint** | **`drafts/planning/<line>/<feature>/`,原樣落地** |
| `pm-intake notion` | 已寫好的 Notion 規格,要排進 sprint | `drafts/<sprint>/<feature>/`,建四件套 + 交棒 `pm-spec write` |
| `pm-plan scope` | 只有一個想法,還沒有素材 | 引導思考 → 建骨架 |

**這個 skill 不做的事**:
- 不判斷這個功能值不值得做(那是 `pm-plan scope`)。
- 不寫 `spec.md` 內文、不建 `decisions.md` / `actions.md` / `changelog.md` 四件套(那是 `pm-intake notion`
  排進 sprint 時才做的事)。
- 不臆測歸類——看不出來屬於哪條產品線、哪個 feature,一律問 PM,不硬塞。
- 不回寫來源(Notion / Google Doc 等仍是唯讀來源)。

預設語言:繁體中文(技術名詞保留英文)。

---

## When To Use

適用:
- PM 貼一份檔案 / 連結 / 直接貼上的內容,說「這是規劃中的 xxx」「幫我歸類」「這個放去 planning」
- 內容可能是 domain model、story mapping 文件、寫到一半的 spec、其他規劃過程產出——**格式不限**
- 還沒明講要放哪條產品線(to-c / to-process / to-r / platform)、哪個 feature 資料夾

不適用(改用別的):
- 已經確定要排進 sprint 開發 → 依 drafts/README.md（`<規格庫>/drafts/README.md`） 正常流程在
  `drafts/<sprint>/<feature>/` 建四件套(可以把 `planning/` 裡累積的素材當起點搬過去)
- 素材是**已經寫好的 Notion 規格**且要排進 sprint → `pm-intake notion`
- 只有一個想法,還沒有任何素材 → `pm-plan scope`

---

## Step 0:開始分類之前先確認(不滿足先別分類)

**接手的東西 = PM 貼的檔案 / 連結 / 貼上的內容**(可能一次一份或多份)。

**放行判斷**(都要有答案才開始)

- [ ] 這份素材講得出來對應「哪個 feature」(哪怕是暫定名稱、還沒定案的代號)。
      沒有 feature 歸屬就分類,之後同一 feature 的素材會散落在不同資料夾,沒人找得回來。
- [ ] 確認這是**規劃階段**、還沒排進 sprint 開發。已經排進 sprint 的話,正確位置是
      `drafts/<sprint>/<feature>/`,不是這裡——放錯地方會讓同一份東西兩邊都留一份,之後分不清哪份是真的。

**提醒,不擋路**

- 一次貼了好幾份不同 feature 的素材 → 逐份判斷歸類,不要合併成一份丟進同一個資料夾。
- 內容裡有圖片 → 提醒 PM 這個 repo 圖片不進版控,稍後要走 `pm-intake notion（圖片搬到 Drive）` 換成 Drive 連結。

**不放行時退回**:已經要排 sprint → 引導去 drafts/README.md（`<規格庫>/drafts/README.md`） 的正常流程
(或 `pm-intake notion`,若來源是 Notion);只有想法沒素材 → `pm-plan scope`。

---

## Step 1:判斷產品線

依 drafts/planning/README.md（`<規格庫>/drafts/planning/README.md`） 裡四條產品線的定義判斷這份素材屬於
`to-c` / `to-process` / `to-r` / `platform` 的哪一條。**這份 README 是唯一的分類依據,不在這支 skill
裡另外複製一份定義**——README 改了,判斷邏輯自動跟著改。

判不出來(素材同時碰兩條線、或看不出屬性)→ 直接問 PM,不自行拍板。

---

## Step 2:判斷 feature 資料夾(既有或新建)

1. 掃這條產品線底下已有的 `<feature-slug>/` 資料夾,看有沒有名稱相符或明顯是同一個 feature 的既有資料夾。
2. **有既有的** → 用既有資料夾,把新素材補進去,不建重複資料夾。
3. **沒有** → 跟 PM 確認一個 kebab-case slug(對齊既有 `drafts/<sprint>/<feature-slug>/` 的命名習慣),新建
   `drafts/planning/<line>/<feature-slug>/`。

---

## Step 3:落地素材

把素材依原本的性質存進 `drafts/planning/<line>/<feature-slug>/`,檔名依內容型態命名,例如:

- `domain-model.md`
- `story-map.md`
- `spec-draft.md`

**不套 `drafts/_meta/` 的四件套模板、不臆測補內容**——素材本來寫到哪就存到哪,缺的部分不要用臆測填滿。
若是既有檔案的更新,直接更新內容,並在檔案開頭加一行「更新於 `<日期>`」留痕。

---

## 落地到 drafts(每次分類都要做)

**產物**:`drafts/planning/<line>/<feature-slug>/<檔名>.md`(新檔,或既有檔案的更新)

**交出去前的放行判斷**(全過才交)

- [ ] 檔案確實落在 `to-c` / `to-process` / `to-r` / `platform` 四條之一底下,沒有留在
      `drafts/planning/` 頂層。頂層只放這條線共用的 README,散落頂層的檔案沒人會去找。
- [ ] 檔案裡沒有本機圖片路徑或裸貼的圖——有圖已走 `pm-intake notion（圖片搬到 Drive）` 換成 Drive 連結,或標記
      `待上傳:<本機暫存位置>`。

**提醒,不擋路**(沒做到會提一句,但可以往下)

- 同一 feature 已有舊素材 → 提醒這是補充而非取代,必要時把新舊內容合併成同一份檔案而不是各開一份。

---

## 收尾與銜接

- 這份素材已經夠完整、PM 確定要排進 sprint 開發 → 依 drafts/README.md（`<規格庫>/drafts/README.md`）
  在對應 sprint 下建正式 feature 資料夾,可以把 `planning/` 裡的素材當起點搬過去(不會自動同步)。
- 素材其實是要搬**已寫好的 Notion 規格**且要排 sprint → `pm-intake notion`。
- PM 想先探索方向、還沒有素材可歸類 → `pm-plan scope`。

**這一輪結束的條件**:貼進來的每一份素材都落到對的產品線 + feature 資料夾,沒有還沒問清楚的歸類問題。

---

## Writing Rules

- 一律繁體中文,技術名詞保留英文。
- 分類**不臆測**:看不出屬於哪條產品線、哪個 feature,一律問 PM,不自行拍板。
- 產品線的定義只住在 drafts/planning/README.md（`<規格庫>/drafts/planning/README.md`）,這支 skill 只引用、不複製。
- 跨檔引用一律用相對 markdown 連結,指到具體檔案(含 `.md`),不用 `[[...]]` wiki 連結。
- 圖片政策沿用 CLAUDE.md（`<規格庫>/CLAUDE.md`）:不進 repo,上傳 Google Drive 後回填連結。
