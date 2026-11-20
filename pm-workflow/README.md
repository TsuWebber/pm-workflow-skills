# pm-workflow

軟體 PM 完整工作流的 Claude Code plugin。11 個 skill，一個階段一個入口，底下用子指令區分：`/pm-<階段> <子指令> [對象]`。

## Skill（11）

| 階段 | Skill | 子指令 |
|---|---|---|
| 0 準備 | [`pm-setup`](skills/pm-setup/SKILL.md) | `init` 專案背景、`tools` 工具安裝、`sync` 規格庫更新 |
| 1 收素材 | [`pm-intake`](skills/pm-intake/SKILL.md) | `notion` Notion 規格與圖片、`meeting` 會議記錄、`material` 零散素材 |
| 1 調研 | [`pm-discover`](skills/pm-discover/SKILL.md) | `cases` 解法案例、`pains` 痛點證據 |
| 1 定方向 | [`pm-plan`](skills/pm-plan/SKILL.md) | `scope` 範圍與 drafts、`decide` 決策文件 |
| 2 寫規格 | [`pm-spec`](skills/pm-spec/SKILL.md) | `write` spec.md、`story` / `flow` 從草稿產出、`reverse` 從程式碼反推、`search` 查現況 |
| 3–5 審查 | [`pm-review`](skills/pm-review/SKILL.md) | `qa`、`readers`、`edge`、`impact`、`consistency`、`polish`、`preflight`、`all` |
| 4 設計對齊 | [`pm-design`](skills/pm-design/SKILL.md) | `dr` 設計修改、`prototype` 互動原型 |
| 6 送審 | [`pm-ship`](skills/pm-ship/SKILL.md) | 不帶＝commit 與開 PR、`suggest` / `apply` PR 建議、`wrap` 收尾、`notion` 展示頁 |
| 7 開票 | [`pm-ticket`](skills/pm-ticket/SKILL.md) | `spec` 依規格拆 FE / BE、`bug`、`sprint-bug`、`task`、`optimization`、`story`、`tech`、`form` |
| 8 上線後 | [`pm-launch`](skills/pm-launch/SKILL.md) | `release` 公告、`archive` 封存、`sync-code` 補現況規格、`retro` 回顧 |
| 每天・每週 | [`pm-report`](skills/pm-report/SKILL.md) | `digest` 改動摘要、`daily`、`weekly` |

## 共用檔案

| 檔案 | 內容 |
|---|---|
| [`shared/floor.md`](shared/floor.md) | 所有 skill 共用的底線：每次執行先做什麼、用語、外部寫入、待確認格式 |
| [`shared/writing.md`](shared/writing.md) | 中英文寫作格式與用語規則 |
| [`shared/principles.md`](shared/principles.md)、[`shared/skill-contract.md`](shared/skill-contract.md) | 調研類 skill 的方法論與 skill 撰寫契約 |

每個 skill 執行前會讀 `~/.claude/pm-config.md`（範本見 repo 根目錄的 [`pm-config.example.md`](../pm-config.example.md)），公司專屬的路徑、ID、名詞都放在那裡，skill 本體不用改。

## 授權

MIT，見 [LICENSE](../LICENSE)。
