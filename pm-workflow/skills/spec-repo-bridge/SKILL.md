---
name: spec-repo-bridge
description: 在任何資料夾叫用 spec repo 的規格 skill 與指令（橋接）。寫規格、方向收斂、寫 AC、挑規格問題、QA 預審、處理設計修改、會議轉待辦、從 Notion 搬規格、開 PR / ship、拆 FE/BE 票、封存 feature、同步最新規格時使用。觸發語如「寫 spec」「spec-plan」「spec-write」「spec-review」「qa-pre-review」「ship」「送審」「規格預審」「拆 FE BE 票」「archive feature」「sync spec repo」「從 Notion 搬進 drafts」。目前工作目錄就是 spec repo 時不需要這個橋接，直接用專案內的 skill。
---

# spec repo 橋接

spec repo 的 skill 與指令都用相對路徑讀寫 repo（`drafts/`、`specs/`、`archive/`、`drafts/_meta/TEMPLATE-*`），所以只能在 repo 裡執行。這個 skill 讓你在其他資料夾也能叫用：讀 repo 裡的原檔，把所有相對路徑換成 repo 的絕對路徑後照做。

**Repo 位置**：`<SPEC_REPO_PATH>`（以下稱 `$SV`）

## 步驟

1. **判斷是否需要橋接**：目前工作目錄已經是 `$SV` → 不用這個 skill，直接用專案內同名的 skill / 指令。
2. **讀 repo 的規則**：先讀 `$SV/CLAUDE.md`，它的規則優先於這份橋接說明。
3. **找到對應的原檔**（見下表），用 Read 讀完整份再照做：
   - skill：`$SV/.claude/skills/<名稱>/SKILL.md`（同資料夾的其他檔案用到才讀）
   - 指令：`$SV/.claude/commands/<名稱>.md`
   - 規格庫裡沒有這份檔案時，改讀本 plugin 的 `skills/<名稱>/SKILL.md` 或 `commands/<名稱>.md`，路徑規則照第 4 步
   - 原檔引用的 `kernel/…` 指 `$SV/.claude/kernel/…`
4. **路徑一律用絕對路徑**：原檔裡的 `drafts/…`、`specs/…`、`archive/…` 等相對路徑，全部視為 `$SV/…`。git 指令用 `git -C "$SV" …`，不要 cd 後依賴目前目錄。
5. **原檔標了 `context: fork`**（例如 `qa-pre-review`）：用 Agent 工具開一個 subagent 執行，把原檔路徑、`$SV` 位置和參數寫進 prompt，結果回報給使用者。
6. **找不到原檔**：本機可能還沒更新。先跑 `git -C "$SV" status -sb` 看是否落後，告訴使用者要先執行 `sync`（照 `$SV/.claude/commands/sync.md` 做），不要自己猜內容。

## 對照表

主線 6 個 🆕（2026-11-20 精簡）：

| 需求 | 名稱 | 類型 |
|---|---|---|
| 要不要做、範圍到哪、建 drafts 資料夾 | `spec-plan` | skill |
| 寫 spec.md 與 AC | `spec-write` | skill |
| QA 角度挑規格問題 | `spec-review` | skill |
| 送審前用 QA 標準完整預審 | `qa-pre-review` | skill（fork） |
| 一鍵 commit、push、開 PR | `ship` | 指令 |
| 依草稿拆 FE / BE 票 | `ticket` | 指令 |

**其他需求**（例如 sync、spec-search、from-notion、to-notion、design-review、meeting-to-actions、archive）：使用者說出指令名稱或描述需求時，到 `$SV/.claude/skills/` 與 `$SV/.claude/commands/` 找同名或描述相符的檔案照做；找不到就列出這兩個資料夾的檔名讓使用者挑，不要自己猜。寫任何規格文字時套用 `$SV/.claude/skills/human-readable-writing/SKILL.md`。

非規格的 Jira 票（Bug、Sprint Bug、Task、簡道雲）、決策文件、release note、文件審查，用 `pm` skill。

## 注意

- 協作守則照常適用：使用者沒說 GO 不寫進 `$SV`；寫完回報絕對路徑、章節與改了哪句。
- 動手前先看 `git -C "$SV" status -sb`，確認目前分支是使用者要改的那一支；要切分支或 commit 先問。
- 寫入 `$SV` 時 App 可能會請使用者核准存取這個資料夾，這是正常的。
