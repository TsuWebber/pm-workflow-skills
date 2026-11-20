---
name: draft-flow
description: |
  依 drafts/ 裡指定的規格檔,產出以使用者目標為維度的 Userflow 文件(前置條件 + 主線步驟表 + 分支與例外 + 結束狀態),
  輸出到同 feature 資料夾的 flows.md。
  來源是 draft spec(不是程式碼;從 repo 程式碼反推用 /output-flow;要規則與判斷依據用 /draft-story)。
  關鍵字:userflow, flow, 流程, 使用者流程, 操作流程, 路徑, draft
argument-hint: <draft 檔案路徑> [輸出路徑]
allowed-tools: Read, Grep, Glob, Bash, Write
---

# 依 draft spec 產出 Userflow（/draft-flow）

## 目的

讀 `drafts/` 裡**指定的規格檔**,把規格描述的操作過程整理成以使用者目標為維度的 Userflow,
輸出成同 feature 資料夾裡的一份文件。讓 PM 寫完 spec 後,能立刻拿到一份 RD 照著串畫面、QA 照著跑步驟的流程清單。

**規範一律依 [specs/docs/USERFLOW-WRITING-GUIDELINES.md](../../specs/docs/USERFLOW-WRITING-GUIDELINES.md)**,本指令不重複規則內文。

## 使用方式

```
/draft-flow [draft_path] [output_path]
```

| 參數 | 必填 | 說明 | 預設 |
|---|---|---|---|
| `[draft_path]` | 否 | `drafts/` 底下的規格檔(通常是 `drafts/<sprint>/<feature>/spec.md`) | 未提供則掃 `git status --porcelain drafts/` 取這次變動的 draft;找不到或有多個候選 → 列出並詢問 |
| `[output_path]` | 否 | 輸出檔位置 | 見「輸出位置規則」 |

## 執行步驟

### 1. 必要性檢查（先判斷要不要寫）

讀規範 §4 的必要性矩陣,逐條比對這份 spec 描述的功能:

- 命中任一「必寫」訊號 → 繼續。
- 全部落在「不寫」欄 → **停手**,回報「依 §4 判定不需要 userflow,理由是 ⋯⋯」,並建議改跑 `/draft-story`。
- 只命中「選寫」 → 詢問使用者要不要產出,不自行決定。

答不出「產出後誰會讀」就停手。這一關是為了不生產沒人讀的文件。

### 2. 讀來源並切出使用者目標

- 讀 `[draft_path]` 全文,以及同 feature 資料夾的 [decisions.md](../../drafts/_meta/TEMPLATE-decisions.md) 決策紀錄。
- 依規範 §2 把功能切成數個 sea level 目標,每個目標一條 flow。
- 標題一律「角色 + 動詞 + 受詞」;切不出結束狀態的候選不成立,合併或捨棄。

### 3. 依規範 §3 檢查複雜度

- 主線超過 9 步 → 按中間的穩定狀態切兩條。
- 出現異步接力(換 app、換操作者身分、狀態留著等人接) → 依 §3.1 拆條,用 `continues-to` / `continues-from` 互指。
- 分支超過 4 條或出現嵌套 → 只留改變結束狀態的,其餘交給 story。

### 4. 填步驟表

- 欄位固定「步驟 / 角色 / 使用者動作 / 系統回應 / 判斷依據」(規範 §5.3)。
- 規劃階段 `fe-route` 標 `TBD（規格未明）`;判斷依據在 spec 沒寫清楚的同樣標 TBD,不臆測。
- 業務規則不寫進 flow,用相對 markdown 連結指向對應 story 或模組規格。

### 4.5 標出無出處的規則

spec 裡描述了行為但 `stories.md` 沒有對應 story 時，依規範 §3.4 列進「待回填 story」清單回報,不要把規則寫進 flow 內文。

### 5. 對應 story

- 掃同 feature 資料夾的 `stories.md`,把每條 flow 對得上的 US 編號填進 `story-refs`。同 feature 只填檔名,跨模組填完整路徑(規範 §5.1)。
- 對不上的標 `TBD（無對應現有 story）`,不硬湊。

### 6. 產出並記錄異動

- 依「輸出位置規則」寫檔。
- 輸出檔已存在 → 讀舊檔記下 `source_spec_version` 與 flow 清單,**就地整份重生**(spec 是唯一真相,flows 是衍生物,不做增量合併)。
- 比對新舊兩版,產出 **Flow 異動摘要**(flow 與步驟層級,標 `[新增]` / `[修改]` / `[刪除]`),追加進輸出檔的「Flow 異動紀錄」章節(最新在上,舊紀錄原封搬回),並列在回報結果裡。
- `source_spec_version` 填來源 `spec.md` 的 `spec_version`;落後於 spec 就代表這份 flows 過期該重跑。

### 7. 自我檢驗（產出前逐條確認）

- 每條 flow 都只服務一個使用者目標嗎?
- 版面改動後這條 flow 還成立嗎?(規範 §8 穩定性)
- 有沒有把 story 的業務規則抄進來?
- 送審前檢查清單(規範附錄)每一項都過了嗎?

## 輸出位置規則

未指定 `[output_path]` 時:

- 來源是 `drafts/<sprint>/<feature>/spec.md` → 輸出 `drafts/<sprint>/<feature>/flows.md`。
- 來源是其他檔 → 同層輸出 `<原檔名去 .md>.flows.md`。
- **一個檔案裝該 feature 的多條 flow**(與 `stories.md` 同慣例);一檔一條是 `/output-flow` 的做法,兩者不混用。

## 輸出檔骨架

```markdown
---
title: "<功能顯示名> — Userflows"
sprint: "<sprint>"
source_spec: "spec.md"
source_spec_version: "<來源 spec_version>"
---

# <功能顯示名> — Userflows

> 來源:[spec.md](./spec.md) v<spec_version>　規範:[USERFLOW-WRITING-GUIDELINES.md](../../../specs/docs/USERFLOW-WRITING-GUIDELINES.md)

## UF-1: <角色 + 動詞 + 受詞>

（frontmatter 欄位以清單列出:app / actor / goal / fe-route / story-refs / spans / continues-to）

### 前置條件
### 主線步驟
### 分支與例外
### 結束狀態
### 流程圖（條件見規範 §6.2）
### 待釐清

## UF-2: ...

## Traceability

| Flow | 對應 Story | 對應模組 |
|---|---|---|

## Flow 異動紀錄

| 日期 | 來源 spec_version | 變動 |
|---|---|---|
```

## 撰寫規則

- 繁體中文;技術名詞(欄位名、狀態 enum、API path)保留英文。
- **提到檔案就要能點得開**:一律用相對 markdown 連結並指到具體檔案(含 `.md`)——同 feature 資料夾 `[spec.md](./spec.md)`,跨區域從 `drafts/<sprint>/<feature>/` 退三層 `[order-management](../../../specs/docs/01-order-lifecycle/order-management/_index.md)`。不要用 `[[...]]` wiki 連結。
- 內容只依 draft **規格本身**;spec 沒寫清楚的不臆測,進「待釐清」。
- 圖一律 Mermaid,不放圖片。

## 定位與分工

- **會不會寫進 `specs/`?** 不會。輸出永遠在 `drafts/<sprint>/<feature>/`;feature 上線後整個資料夾由 `/archive` 封存,flows.md 跟著資料夾走。上線後若要在 `specs/` 留一份現況 flow,那是 `/output-flow` 從實作反推的事。
- **與 `/draft-story` 的分工**:flows 管**怎麼走**(路徑與導覽),stories 管**憑什麼**(規則與判斷依據)。同一條規則不在兩邊各寫一次。
- **PM 改了 spec 怎麼辦?** spec.md 是唯一真相:改 spec → `spec_version` +0.1 → 重跑 `/draft-flow`,「Flow 異動紀錄」會留下這次哪些 flow 與步驟變了。

## 注意事項

- 來源一律是 `drafts/`;不從 `specs/`、`archive/` 產 flow。
- 本指令**只產文件**:不建 JIRA 票(那是 `/ticket`)、不從程式碼反推(那是 `/output-flow`)、不改 spec.md 本身。
- **不要**執行任何 `git commit` / `git push`;要送審用 `/ship` 或 `/pr`。
- flows.md 是衍生物,不寫進 changelog.md(changelog 只記 spec 本身的異動)。
