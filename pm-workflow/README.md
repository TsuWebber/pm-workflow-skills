# pm-workflow

軟體 PM 工作流的 Claude Code plugin。一個 skill `pm`，9 個子指令，用法是 `/pm <指令> [對象]`。只打 `/pm` 時，會判斷你目前在哪個階段，建議下一步。

## Skill（1）

| Skill | 說明 |
|---|---|
| [`pm`](skills/pm/SKILL.md) | PM 工作流入口。每個子指令的做法放在 `reference/<指令>.md`，用到才讀 |

## 子指令（9）

| 分類 | 指令 | 做什麼 |
|---|---|---|
| 準備 | `init` | 建立專案背景 `.pm/PROJECT.md`，之後每個指令都會讀 |
| 產出 | `decide` | 重大改動的決策文件：為什麼改、有哪些選項、建議選哪個 |
| | `release` | 給業務、營運、客服看的 release note |
| | `ticket` | Jira 開票：Bug、Sprint Bug、Task、優化、需求、技術、通報 |
| 審查 | `review` | 規則檢查（P0 / P1 / P2）＋讀者角色審查，合併成一份清單 |
| 補強 | `harden` | 補狀態、逆向流程、權限、資料異常、上限 |
| | `impact` | 盤點對各部門的影響、要誰配合、誰拍板 |
| | `distill` | 壓縮冗長內容，規則與數字一個都不刪 |
| | `clarify` | 統一用語、消除模糊詞 |

## 作者

[TsuWebber](https://github.com/TsuWebber)

## 授權

MIT，見 [LICENSE](../LICENSE)。
