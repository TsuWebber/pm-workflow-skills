# PM Workflow Skills

我身為軟體 PM，每天實際在用的一整套 Claude Code skill：從調研、定方向、寫規格、審查、送審、開票、上線，到每天和每週的進度同步。

規格寫在團隊用 Git 管理的規格庫，用草稿、PR、審查的方式迭代；規格以外的決策、審查、開票與公告，交給一個 `/pm` 入口；每天早上自動整理昨天的改動，同步給各專案群組。

一個 plugin `pm-workflow`：**24 個 skill、13 個 command、2 個 agent**，全部用繁體中文產出。

- 📝 我自己撰寫：`pm`、`spec-repo-bridge`、`spec-revise`、`change-digest-mode`、`daily-report-mode`、`weekly-recap-mode`、`retro-mode`
- 👥 改寫自團隊共用的規格庫：其他所有 skill、command 與 agent

## 實際使用情況

2026 年 7 月中到 11 月中，我在 Claude Code 裡叫用的次數（不含排程自動執行）：

| Skill / Command | 次數 | 用途 |
|---|---|---|
| 開 Jira 票（`pm ticket` 與前身） | 21 | Bug、Sprint Bug、Task、需求票 |
| `ship` | 14 | 規格送審：commit、開 PR |
| `spec-write` | 11 | 寫規格與 AC |
| `spec-plan` | 9 | 動筆前收斂方向 |
| `pm`（其他子指令） | 9 | 決策文件、審查、release note |
| `setup` | 7 | 規格庫工具安裝與授權 |
| `weekly-recap-mode` | 6 | 個人週報 |
| `sync` | 5 | 規格庫更新到最新 |
| `spec-review`、`spec-search`、`ticket`、`archive` | 各 3 | 挑規格問題、查現況、拆票、封存 |
| `from-notion` | 2 | Notion 規格搬進規格庫 |

另外 `change-digest-mode` 由排程在每個工作日早上自動執行。

## 完整工作流程

```
需求進來
│
├─ 0 準備
│   ├─ 📝 pm init ..................... 建立專案背景 .pm/PROJECT.md
│   ├─ 👥 setup ....................... 規格庫工具安裝與授權（第一次）
│   └─ 👥 /sync ....................... 規格庫更新到最新
│
├─ 1 調研・定方向
│   ├─ 👥 discovery-case-scan ......... 別人怎麼做、誰做不好
│   ├─ 👥 discovery-pain-evidence ..... 這個痛是真的嗎：可追溯的實例證據
│   ├─ 👥 to-planning ................. 零散素材整理進規劃
│   ├─ 👥 from-notion ................. Notion 上的舊規格搬進 drafts
│   ├─ 👥 meeting-to-actions .......... 會議記錄轉成決策、待辦、規格增補提案
│   ├─ 👥 spec-plan ................... 要不要做、範圍到哪、建 drafts 資料夾
│   └─ 📝 pm decide ................... 重大改動要拍板時，寫決策文件
│
├─ 2 寫規格
│   ├─ 👥 spec-write .................. 寫 spec.md，AC 與指標一起寫
│   ├─ 👥 /spec-search ................ 查某個邏輯目前寫在哪些規格
│   ├─ 👥 /draft-story、/draft-flow ... 從草稿產出 User Story、Userflow
│   ├─ 👥 /output-story、/output-flow . 從程式碼反推現況規格
│   ├─ 👥 human-readable-writing ...... 寫任何規格文字時套用的格式規則
│   └─ 👥 images-to-drive ............. 規格圖片搬到 Drive，不進 repo
│
├─ 3 補強
│   ├─ 📝 pm harden ................... 補邊界、例外、逆向流程
│   ├─ 📝 pm impact ................... 盤點各部門影響、誰配合、誰拍板
│   └─ 📝 pm clarify / distill ........ 統一用語、精簡
│
├─ 4 審查・設計對齊
│   ├─ 👥 spec-review ................. QA 角度挑缺漏、模糊、衝突
│   ├─ 📝 pm review ................... 規則檢查＋讀者角色審查
│   ├─ 👥 design-review ............... 設計師的修改記成 DR，PM 拍板才改規格
│   └─ 👥 prototype ................... 做可操作的 prototype 驗證流程
│
├─ 5 送審前自查
│   ├─ 👥 qa-pre-review ............... 用 QA 的標準在獨立 context 完整預審
│   └─ 📝 spec-revise ................. 全文掃矛盾：AC 與內文、公式邊界、狀態流轉
│
├─ 6 送審
│   ├─ 👥 /ship ....................... 分組 commit、push、開 PR
│   ├─ 👥 pr-suggest / pr-apply-suggestions  審 PR 留建議、收到建議後套用
│   ├─ 📝 spec-revise ................. 收尾：changelog、群組同步文字
│   └─ 👥 to-notion ................... 定案的規格輸出成 Notion 展示頁
│
├─ 7 開票
│   ├─ 👥 /ticket ..................... 依規格拆前端 / 後端 User Story
│   └─ 📝 pm ticket ................... Bug、Sprint Bug、Task、優化
│
└─ 8 上線後
    ├─ 📝 pm release .................. 給業務、營運、客服看的 release note
    ├─ 👥 /archive .................... feature 從 drafts 封存
    ├─ 👥 /sync-code .................. 程式碼的新行為補進現況規格
    └─ 📝 retro-mode .................. 專案回顧 Keep / Problem / Try
```

跟著時間跑、不屬於單一需求的：

```
每天・每週
├─ 📝 change-digest-mode ... 工作日早上由排程整理昨天在 Notion、Jira、規格庫的改動與群組結論，依專案產出群組訊息
├─ 📝 daily-report-mode .... 從任務資料庫與行事曆產生 Daily 回報
└─ 📝 weekly-recap-mode .... 從週會筆記、行事曆、任務資料庫產生週報（結果版＋個人紀錄版）
```

## 為什麼這樣設計

- **規格只有一個來源。** 規格只寫在規格庫，Notion 只做單向輸出。`pm` 不寫規格，但它的審查與補強指令可以直接讀 `spec.md`。
- **兩段分工，交棒點固定。** 規格 skill 負責「寫、審、送」，`pm` 負責「拍板、補強、開票、公告」。兩邊都有開票：依規格拆的開發票走 `/ticket`，開發期間的 bug 與任務走 `pm ticket`。
- **一個入口，按需載入。** `pm` 9 個子指令共用一個入口，每個指令的做法放在 `reference/<指令>.md`，用到才讀。
- **跨資料夾用橋接，不複製。** 規格 skill 依賴規格庫的資料夾結構，只能在 repo 裡執行。`spec-repo-bridge` 讓我在任何資料夾叫用它們，讀的是 repo 裡的原檔。
- **先給草稿，再動外部系統。** 寫入檔案、Notion、Jira、Git 前一律先列提案，確認後才執行。
- **不推論。** 業務規則、名詞、角色不確定時，標 `🟡 待確認` 並附假說，不自己補。
- **獨立 context 審查。** `qa-pre-review` 刻意看不到前面的對話，避免作者的說明影響審查結果。

## 迭代紀錄

- **規格從 Notion 搬到規格庫。** `pm` 原本有 `shape`、`spec`、`ac` 三個指令產出 Notion PRD。團隊改用規格庫後封存，改由規格 skill 負責。
- **審查合併。** `critique`（讀者角度）和 `audit`（規則檢查）幾乎每次都一起跑，合併成 `review`。
- **橋接取代切換資料夾。** 規格 skill 原本只能在規格庫裡用，加了 `spec-repo-bridge` 之後，在任何專案資料夾都能叫用。

## 安裝

### Claude Code（CLI）

```bash
claude plugin marketplace add TsuWebber/pm-workflow-skills
```

```bash
claude plugin install pm-workflow@pm-workflow-skills
```

### 只要部分 skill

把 `pm-workflow/skills/` 底下想用的資料夾複製到 `~/.claude/skills/`，`pm-workflow/commands/` 底下的檔案複製到 `~/.claude/commands/`。

## 設定

### 規格庫結構

規格 skill 讀寫規格庫裡的固定位置：

```
spec-repo/
├─ drafts/
│   ├─ _meta/TEMPLATE-*.md ...... 規格模板
│   └─ <sprint>/<feature>/ ...... 草稿：spec.md、decisions.md、actions.md
├─ specs/docs/<模組>/ ........... 已上線的規格
└─ archive/<sprint>/<feature>/ .. 已封存的 feature
```

模板與既有規格屬於各團隊自己的內容，不在這個 repo 裡。PR 平台預設是 Gitea，用其他平台要調整 `ship`、`pr`、`pr-suggest`、`pr-apply-suggestions`。

### 佔位符

| 佔位符 | 換成 |
|---|---|
| `<SPEC_REPO_PATH>` | 規格庫在本機的路徑 |
| `<GIT_HOST>`、`<ORG>`、`<SPEC_REPO>` | Git 平台、組織、規格庫名稱 |
| `your-team.atlassian.net`、`PROJ-xxx` | Jira 網域與專案代碼 |
| `<CUSTOM_FIELD_ID>`、`<TEAM_NAME>` | Jira 自訂欄位 ID、team 名稱 |
| `<NOTION_ID>`、`<NOTION_DB_ID>`、`<PAGE_ID>` | Notion 頁面與資料庫 ID |
| `<DINGTALK_EXPORT_DIR>` | 群組對話匯出的資料夾（`change-digest-mode`、`retro-mode`） |
| `pm-workflow/skills/pm/reference/ticket/references/epic-mapping.md` | 你的 Epic 清單 |

公司專有名詞與部門職責建議寫在自己的 `~/.claude/CLAUDE.md`，skill 會以它為準。

## 來源與去識別

- 📝 標示的 skill 由我撰寫。
- 👥 標示的 skill、command 與 agent 改寫自我所在團隊共用的規格庫，原作者為團隊成員，經同意以去識別形式公開。
- 公司名稱、內部系統代號、品牌、人名、網址、ID、票號、本機路徑都已換成通用名稱或佔位符。

## 授權

MIT，見 [LICENSE](LICENSE)。
