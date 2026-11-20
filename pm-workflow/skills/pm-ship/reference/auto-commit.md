# Auto Commit — 智慧自動分組提交（spec repo）

分析所有未提交變更,依「內容領域」智慧分組,一組一個 commit。
本 repo 是 **Markdown 規格庫**,沒有程式碼——分組依規格區塊,不是依 code layer。

## 執行步驟

1. 取得所有未提交變更(`git status`、`git diff`、`git diff --cached`)。
2. 判斷每個檔案屬於哪個區塊(見下方分組策略)。
3. **範圍守門**:若變更包含 `specs/`、`frontend/`、`routes/`、`userflows/`(這些是別的 repo 同步進來的產物,不該在此手改)→ 先提醒使用者,確認後再決定是否納入,不要靜默一起 commit。
4. 依分組逐一 `git add <該組檔案>` → `git commit`。**不要 `git add -A` 把全部混成一包。**
5. Commit 訊息**不含任何 AI 標記**:
   - 不要出現 `Generated with [Claude Code]`
   - 不要出現 `Co-Authored-By: ...`

## Commit 訊息格式

`<type>(<scope>): <內容>`(scope 可省;英文內容以小寫開頭)

- `draft(<sprint>)`:`drafts/<sprint>/` 的草稿變更(例:`draft(2606): 新增疊券規則草稿`)
- `docs`:`index.md`、各 `README.md`、`CLAUDE.md`、`AUDIT.md` 等倉庫文件
- `docs(archive)`:`archive/` 底下的封存 feature（一般只由 `pm-launch archive` 產生變更）
- `chore`:`.claude/`、`.gitignore` 等工具與設定

要求:
- 主題行 ≤ 72 字元,**不以標點結尾**
- 主題與內文之間空一行;內文說明 why / what,不說 how
- 多點用清單呈現

## 分組策略（依內容領域）

| 群組 | 對應路徑 |
|---|---|
| 草稿(依 sprint 再分) | `drafts/<sprint>/...` — 不同 sprint 拆不同 commit |
| 封存區 | `archive/...` |
| 倉庫說明文件 | `index.md`、`*/README.md`、`CLAUDE.md`、`AUDIT.md` |
| 工具與設定 | `.claude/...`、`.gitignore` |

### 分組原則

- **同一份草稿的多檔一起提交**(例如一個功能的草稿 + 它引用的圖)。
- **不同 sprint、不同區塊分開提交**,讓歷史清楚。
- 一個 commit 只講一件事;跨區塊的變更拆成多個 commit。

### 提交順序（由基礎到內容）

1. 工具與設定(`.claude/`、`.gitignore`)
2. 倉庫說明文件(README / CLAUDE / index)
3. 封存區(`archive/`)
4. 草稿(`drafts/`)

## 安全檢查

- 確認沒有誤把四個現況區的同步產物一起提交。
- 確認沒有殘留敏感資訊(token、內部 URL 以外的密鑰等)。
- 每組提交內容自洽、可獨立閱讀。

開始自動提交流程…