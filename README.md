# PM Workflow Skills

我在工作中最常用、也最精簡的一套 PM skill。它把需求從零散資訊推進到可交付的文件與工單：決策文件、release note、Jira 開票，以及對任何文件的審查與補強。

整套只有一個 skill `pm`，9 個子指令，全部用繁體中文產出。

## 從這裡開始

```
/pm                      判斷目前在哪個階段，建議下一步
/pm review spec.md       審一份規格：規則檢查＋讀者角色，依嚴重度排序
/pm harden spec.md       找出漏掉的邊界、例外、逆向流程
/pm impact spec.md       盤點對營運、財務、物流、客服的影響
/pm decide               整理一份決策文件給主管拍板
/pm ticket               開 Jira 票
/pm release              寫給使用單位看的 release note
```

## 為什麼這樣設計

- **一個入口，按需載入。** 9 個子指令共用一個 `/pm`，每個指令的完整做法放在 `reference/<指令>.md`，用到才讀，不會一次塞滿 context。
- **讀者決定寫法。** 先判斷產出給誰看：給工程和 QA 的要能驗證，給主管的要能拍板，給業務和客服的要講結果不講系統。
- **先給草稿，再動外部系統。** Notion、Jira 的寫入一律等使用者明確指示；一次動多張票會先列清單。
- **不推論。** 資訊不足時在原處標 `🟡 待確認`，不自己補規則。
- **寫規格不在這裡。** 規格寫在團隊用 Git 管理的規格庫，`pm` 負責規格以外的事，但可以直接審規格檔。

## 工作流程

```
需求進來
├─ init ............ 建立專案背景（每個專案一次）
├─ decide .......... 影響大、要拍板時先寫決策文件
├─【規格庫】寫規格
├─ review .......... 規則檢查＋讀者審查
├─ harden .......... 補邊界與例外
├─ impact .......... 盤點跨部門影響
├─ distill / clarify 精簡、統一用語
├─【規格庫】預審、送審
├─ ticket .......... 開票
└─ release ......... 上線公告
```

不需要每一步都走，依當下進度挑。

## 子指令

| 分類 | 指令 | 做什麼 | 讀者 |
|---|---|---|---|
| 準備 | `init` | 建立 `.pm/PROJECT.md`：產品線、系統、使用單位、部門、baseline | 自己 |
| 產出 | `decide` | 決策文件：背景、選項比較、建議 | 主管、跨部門 |
| | `release` | release note：上了什麼、怎麼用、對我有什麼影響 | 業務、營運、客服 |
| | `ticket` | Jira 開票，依情境選票型（見下方） | 工程、QA |
| 審查 | `review` | 第一段依底線規則逐條檢查（P0 / P1 / P2），第二段模擬工程、QA、設計、營運、財務讀完會卡在哪，合併成一份清單 | 文件作者 |
| 補強 | `harden` | 狀態轉換、取消與退貨等逆向流程、權限、資料異常、0 筆與上限 | 工程、QA |
| | `impact` | 各部門受到什麼影響、要準備什麼、誰拍板 | 主管、跨部門 |
| | `distill` | 刪重複與鋪陳，規則、數字、待確認一個都不刪 | 所有人 |
| | `clarify` | 統一系統名稱與同義詞，把模糊詞與相對時間改具體 | 所有人 |

`ticket` 的票型：Bug、Sprint Bug（掛在 Epic 的 bug 區）、Task、優化、需求（依規格批次建 Epic 與 Story）、技術、表單通報。

## 安裝

### Claude Code（CLI）

```bash
claude plugin marketplace add TsuWebber/pm-workflow-skills
```

```bash
claude plugin install pm-workflow@pm-workflow-skills
```

### 只要 skill

把 [`pm-workflow/skills/pm`](pm-workflow/skills/pm) 整個資料夾複製到 `~/.claude/skills/`。

## 設定

檔案裡有幾個佔位符要換成自己環境的值：

| 佔位符 | 換成 |
|---|---|
| `your-team.atlassian.net` | 你的 Jira 網域 |
| `PROJ-xxx` | 你的 Jira 專案代碼與票號 |
| `<CUSTOM_FIELD_ID>` | Jira 自訂欄位 ID（Team、Sprint、Environment） |
| `<NOTION_ID>`、`<NOTION_DB_ID>` | Notion 頁面與資料庫 ID |
| `reference/ticket/references/epic-mapping.md` | 你的 Epic 清單 |

公司專有名詞與部門職責建議寫在自己的 `~/.claude/CLAUDE.md`，`pm` 會以它為準。

## 授權

MIT，見 [LICENSE](LICENSE)。
