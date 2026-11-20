# pm-workflow

軟體 PM 完整工作流的 Claude Code plugin。依工作階段整理如下，📝 為作者自己撰寫，👥 改寫自團隊共用的規格庫。

## Skill（24）

| 階段 | Skill | 來源 | 做什麼 |
|---|---|---|---|
| 準備 | [`pm`](skills/pm/SKILL.md) | 📝 | PM 工作流入口，9 個子指令（init、decide、release、ticket、review、harden、impact、distill、clarify） |
| | [`setup`](skills/setup/SKILL.md) | 👥 | 一次裝好規格庫需要的工具並完成授權 |
| | [`spec-repo-bridge`](skills/spec-repo-bridge/SKILL.md) | 📝 | 在規格庫以外的資料夾叫用規格 skill |
| 調研・定方向 | [`discovery-case-scan`](skills/discovery-case-scan/SKILL.md) | 👥 | 收集解法案例：別人怎麼做、誰做不好 |
| | [`discovery-pain-evidence`](skills/discovery-pain-evidence/SKILL.md) | 👥 | 把痛點落成可追溯的實例證據 |
| | [`to-planning`](skills/to-planning/SKILL.md) | 👥 | 還沒成形的規劃素材整理進流程 |
| | [`spec-plan`](skills/spec-plan/SKILL.md) | 👥 | 想清楚要不要做、範圍到哪，建 drafts 資料夾 |
| | [`meeting-to-actions`](skills/meeting-to-actions/SKILL.md) | 👥 | 會議記錄轉成決策、待辦與規格增補提案 |
| | [`from-notion`](skills/from-notion/SKILL.md) | 👥 | Notion 上的規格搬進 drafts |
| 寫規格 | [`spec-write`](skills/spec-write/SKILL.md) | 👥 | 寫 spec.md，含 AC 與指標 |
| | [`human-readable-writing`](skills/human-readable-writing/SKILL.md) | 👥 | 中英文寫作格式與用語規則 |
| | [`images-to-drive`](skills/images-to-drive/SKILL.md) | 👥 | 規格圖片搬到 Google Drive，換成連結 |
| 審查・設計對齊 | [`spec-review`](skills/spec-review/SKILL.md) | 👥 | QA 角度挑規格問題 |
| | [`design-review`](skills/design-review/SKILL.md) | 👥 | 設計師修改記成 DR，PM 拍板才改規格 |
| | [`prototype`](skills/prototype/SKILL.md) | 👥 | 做可在瀏覽器操作的互動 prototype |
| 送審前自查 | [`qa-pre-review`](skills/qa-pre-review/SKILL.md) | 👥 | 用 QA 的標準在獨立 context 完整預審 |
| | [`spec-revise`](skills/spec-revise/SKILL.md) | 📝 | 全文掃矛盾；送審後收尾 |
| 送審 | [`pr-suggest`](skills/pr-suggest/SKILL.md) | 👥 | 審 PR 時留行內修改建議 |
| | [`pr-apply-suggestions`](skills/pr-apply-suggestions/SKILL.md) | 👥 | 收到建議後核對並套用 |
| | [`to-notion`](skills/to-notion/SKILL.md) | 👥 | 定案的規格輸出成 Notion 展示頁 |
| 上線後 | [`retro-mode`](skills/retro-mode/SKILL.md) | 📝 | 專案回顧 Keep / Problem / Try |
| 每天・每週 | [`change-digest-mode`](skills/change-digest-mode/SKILL.md) | 📝 | 每天早上整理昨天的改動，產出各專案群組訊息 |
| | [`daily-report-mode`](skills/daily-report-mode/SKILL.md) | 📝 | Daily 工作回報 |
| | [`weekly-recap-mode`](skills/weekly-recap-mode/SKILL.md) | 📝 | 個人週報 |

## Command（13）

| 階段 | Command | 做什麼 |
|---|---|---|
| 準備 | [`sync`](commands/sync.md) | 規格庫更新到最新，草稿不會弄丟 |
| 寫規格 | [`spec-search`](commands/spec-search.md) | 查某個功能邏輯寫在哪些規格 |
| | [`draft-story`](commands/draft-story.md)、[`draft-flow`](commands/draft-flow.md) | 從草稿產出 User Story 或 Userflow |
| | [`output-story`](commands/output-story.md)、[`output-flow`](commands/output-flow.md) | 從程式碼反推現況規格 |
| 送審 | [`ship`](commands/ship.md) | 分組 commit、push、開 PR |
| | [`pr`](commands/pr.md)、[`commit`](commands/commit.md)、[`auto-commit`](commands/auto-commit.md) | 只開 PR、只 commit（`ship` 內部也會用） |
| 開票 | [`ticket`](commands/ticket.md) | 依規格拆前端 / 後端 User Story |
| 上線後 | [`archive`](commands/archive.md) | 已上線的 feature 從 drafts 封存 |
| | [`sync-code`](commands/sync-code.md) | 把程式碼的新行為補進現況規格 |

Command 全部改寫自團隊共用的規格庫（👥）。

## Agent（2）

| Agent | 做什麼 |
|---|---|
| [`discovery`](agents/discovery.md) | 調研段的路由：案例、痛點證據、綜合結論 |
| [`delivery`](agents/delivery.md) | 交付段的路由：寫規格、挑問題、產 story、送審、封存 |

`kernel/` 是調研 skill 共用的原則與契約。

## 授權

MIT，見 [LICENSE](../LICENSE)。
