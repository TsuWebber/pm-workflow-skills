# Changelog

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
