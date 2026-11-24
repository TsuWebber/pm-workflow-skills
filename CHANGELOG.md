# Changelog

## 3.2.0（2026-11-24）

- `pm-discover` 新增子指令 `compete`：一間競品派一個 subagent 平行調研，用公開資料、前台實測、後台只讀三種查法，主 agent 核對後產出比較矩陣與 CASE 檔
- `cases` 的素材來源補上 `compete`，兩者的 CASE 格式相同，實測完直接接 `cases` 收斂

## 3.1.0（2026-11-20）

- 依實際叫用測試修正：所有落檔先等 GO（`pm-review qa` 原本會直接寫檔）
- 共用底線新增「環境差異」：沒有 remote 或不是 Gitea、規格庫檔案不存在、章節與模組以規格庫實際為準、代碼與平台讀 pm-config、取用憑證前先徵得同意、嚴重度與待確認寫法統一
- 修正斷掉的連結與相對路徑（shared/、ship、pr、ticket、reverse-story、規格庫模板）
- `pm-review readers` 的規則同時支援 Notion A-x 與規格庫 STORY / AC 格式；`consistency` 會對照現況規格
- `pm-ticket`：子指令與票型對照補齊（含 tech、form），bug / sprint-bug 先問清楚，專案代碼讀 pm-config，`spec` 在沒有 Jira 連線時仍產出草稿
- `pm-launch release` 可以直接吃規格庫路徑；`pm-spec write` 的 AC 編號與標籤寫清楚
- README 新增「適合誰用」與「和 phuryn/pm-skills 的差別」

## 3.0.0（2026-11-20）

- 依工作階段重組成 11 個 skill：pm-setup、pm-intake、pm-discover、pm-plan、pm-spec、pm-review、pm-design、pm-ship、pm-ticket、pm-launch、pm-report
- 原本的 skill 與 command 改成各 skill 底下的子指令，做法放在 `reference/`
- 兩套開票合成 `pm-ticket`；審查、補強、自查合成 `pm-review`（新增 `all`）；commit、PR、收尾合成 `pm-ship`
- 寫作規則、共用底線、調研原則合成 `shared/`
- 拿掉 `spec-repo-bridge` 與 2 個 agent；公司專屬設定改放 `~/.claude/pm-config.md`，新增範本 `pm-config.example.md`

## 2.0.0（2026-11-20）

- 合併成單一 plugin `pm-workflow`，依工作階段呈現完整流程
- 新增作者自己的 skill：spec-repo-bridge、spec-revise、change-digest-mode、daily-report-mode、weekly-recap-mode、retro-mode
- 新增改寫自團隊規格庫的 skill、command 與 agent：調研、規格撰寫與審查、PR、封存、同步等
- README 改為完整工作流程，補上實際使用情況、分工與迭代紀錄

## 1.0.0（2026-11-20）

- 首次公開：`pm` skill，9 個子指令（init、decide、release、ticket、review、harden、impact、distill、clarify）
