---
name: archive
description: |
  把 drafts/ 裡已上線(或已終結)的 feature 資料夾封存進 archive/<sprint>/<feature>/:
  補 frontmatter(released_sprint / merged_into)→ 修全 repo 引用 → git mv 原封搬移
  →(結尾詢問或 --pr)開分支 commit push 並在 Gitea 開 PR 送審。
  也支援 --restore 把封存的 feature 搬回 drafts/ 重開。

  使用時機:
  (1) feature 已部署上線,drafts 資料夾要收尾
  (2) feature 確定不做了,要終結歸檔
  (3) 封存過的功能同 sprint 又要改,要搬回 drafts 重開

  關鍵字:archive, 封存, 歸檔, released, 上線收尾, restore, 重開
---

# Archive - 封存已結案的 feature 資料夾

> **IMPORTANT**:本指令只搬 `drafts/<sprint>/<feature>/` ↔ `archive/<sprint>/<feature>/`,
> 不動 `specs/`、`userflows/` 的內容。
> 送審平台是 **Gitea**(不是 GitLab):搬完後**詢問使用者**是否直接開 PR(帶 `--pr` 就不問直接開);
> 不開 PR 就不 commit / push,提醒接 `/ship` 或 `/commit`。

## 使用方式

```
/archive [<sprint>/<feature>] [--pr]
/archive --restore <sprint>/<feature>
```

| 參數 | 必填 | 說明 | 預設 |
|---|---|---|---|
| `[<sprint>/<feature>]` | 否 | 要封存的 feature,例:`2606/product-master` | 未提供則走 Phase 1 的引導式提問 |
| `[--pr]` | 否 | 封存完直接開分支 → commit → push → 開 Gitea PR,不再詢問 | 未帶則在 Phase 6 詢問 |
| `--restore <sprint>/<feature>` | 否 | 反向:把 `archive/<sprint>/<feature>/` 搬回 `drafts/` 重開 | — |

---

## 執行流程(封存)

### Phase 1: 引導定位與前置檢查

> 使用者**不會知道這個 skill 的本質**,也不欠你 `<sprint>/<feature>` 格式。
> 沒給參數就主動問,一步一步來,不要自己猜。

- 有給 `<sprint>/<feature>` 參數 → 直接用,跳到前置檢查。
- 沒給參數 → 兩步引導:
  1. **問 sprint**:列出 `drafts/` 下所有 sprint 資料夾(各附 feature 數),問「要封存哪個 sprint 的功能?」
  2. **問 feature**:列出該 sprint 下所有 feature(附 `title`),問「要封存哪一個?」
     就算候選只有一個也要確認,不自動選。
- 使用者用功能名稱 / 口語描述指功能(如「商品主檔那個」)→ 全 drafts 掃 `spec.md` 的 `title` / `feature` 比對,
  找到後**回報完整路徑請使用者確認**;比對到多個(跨 sprint 同名)→ 列出讓使用者挑。

前置檢查:

- 確認 `drafts/<sprint>/<feature>/` 存在且含 `spec.md`。
- **停下來問**:「這個 feature 確定已上線 / 已終結嗎?」使用者確認才往下;不確認就停止。
- 撞名檢查:`archive/<sprint>/<feature>/` 已存在 → **停止並說明**
  (正常不該發生;同 sprint 重開應走 `--restore` 同路徑進出,不要複製出第二份)。

### Phase 2: 確認整併去向(merged_into)

- 問使用者:「這份 spec 上線後併進現況的哪裡?」——這是**最後一次知道答案的機會**。
  - 正常上線 → 填對應的現況規格位置,寫成從 `archive/<sprint>/<feature>/` 出發的相對連結(例 `[coupon](../../../specs/docs/05-product-and-marketing/coupon/_index.md)`)。
  - 功能終結、沒有併入 → 填 `N/A(未併入,原因:<一句話>)`。
  - 使用者說不知道 → 寫 `TBD(規格未明)` 並在輸出提醒;**不要臆測**。
- 問使用者:「這個功能是在**哪個 sprint** 上線的?」(`released_sprint`,例:`2610`)。
  - **不要問日期**——PM 的時間座標是 sprint,不是日曆;確切日期 git log 都有。
  - 可從對話 / 近期 sprint 推斷一個候選讓使用者確認,但**拍板權在使用者**。
  - 注意 `released_sprint` 可能**不等於**資料夾的 `<sprint>`(起草 sprint):跨 sprint 上線很常見。

### Phase 3: 補 frontmatter

在 `spec.md` frontmatter 加兩個欄位(已存在則更新):

```yaml
released_sprint: <上線的 sprint,例:2610>
merged_into: <相對連結指向併入的現況規格,例 [coupon](../../../specs/docs/05-product-and-marketing/coupon/_index.md);或 N/A(...)>
```

### Phase 4: 修引用(搬移前必做)

- 全 repo grep 舊路徑字串 `drafts/<sprint>/<feature>`(排除 `.git/`、`node_modules/`、`archive/`),
  把命中處改寫為 `archive/<sprint>/<feature>`。
- feature 資料夾**內部**的相對連結(`./decisions.md` 等)不用動——整包搬移不會斷。
- 逐檔列出改了哪些引用;一處都沒有也要說明「無外部引用」。

### Phase 5: 搬移

```bash
git mv drafts/<sprint>/<feature> archive/<sprint>/<feature>
```

- 用 `git mv` 保留歷史;`archive/<sprint>/` 不存在時直接建立。
- **`<sprint>` 一律沿用 drafts 裡的 sprint(路徑純鏡像),不是封存當下的 sprint**:
  2608 起草、2610 才上線的功能仍搬進 `archive/2608/<feature>/`,上線 sprint 記在 `released_sprint`。
- `prototype/` 等子資料夾跟著整包走,不拆。

### Phase 6: 開 Gitea PR(選用)

- 帶 `--pr` → 直接執行;沒帶 → **問使用者**:「要直接開 Gitea PR 送審嗎?」不要就跳到 Phase 7。
- 流程(沿用 `/pr` 的 Gitea 慣例,不要用 `glab` / GitLab):
  1. 在 `main` 上 → 先開分支 `archive/<sprint>-<feature-slug>`;已在其他分支 → 沿用並跟使用者確認。
  2. 只 stage 這次封存動到的檔案(搬移的資料夾、引用修正),
     單一 commit,訊息英文 conventional style:`chore: archive <sprint>/<feature-slug> (released in <released_sprint>)`。
  3. push 後沿用 `/pr` 在 Gitea 開 PR(目標 `main`)。
  4. PR 描述含:搬移路徑(from → to)、`released_sprint`、`merged_into`、引用修正清單、尚未定案的 TBD 提醒。
- 有其他**不相干的 uncommitted 變更** → 不要混進來,列出並告知使用者它們留在 working tree。

### Phase 7: 輸出結果

```
✅ 封存完成

📦 drafts/<sprint>/<feature>/ → archive/<sprint>/<feature>/
   released_sprint: <上線 sprint>
   merged_into: <去向>

🔗 修正的引用(<N> 處):
- <file>:<line> ...

🔀 PR: <Gitea PR URL>(有開 PR 時)
👉 下一步:未開 PR 時 → /ship 或 /commit 送出這批變更
⚠️ 提醒(如有):merged_into 仍為 TBD,記得補
```

---

## 執行流程(--restore 重開)

1. 沒給 `<sprint>/<feature>` → 同 Phase 1 引導式提問(改列 `archive/` 的內容讓使用者挑)。
2. 確認 `archive/<sprint>/<feature>/` 存在;`drafts/<sprint>/<feature>/` 已存在 → 停止並說明。
3. `git mv archive/<sprint>/<feature> drafts/<sprint>/<feature>`(同路徑搬回)。
4. 全 repo grep `archive/<sprint>/<feature>` 引用改回 `drafts/<sprint>/<feature>`。
5. `spec.md` frontmatter:`released_sprint` / `merged_into` **保留**
   (那是上一輪上線的紀錄;再次封存時更新)。
6. 同封存流程 Phase 6:詢問(或依 `--pr`)是否直接開 Gitea PR,分支名 `restore/<sprint>-<feature-slug>`,
   commit 訊息 `chore: restore <sprint>/<feature-slug> from archive`。
7. 輸出結果;未開 PR 時提醒接 `/ship` 或 `/commit`。

---

## 注意事項

- 「不搬資料夾」原則(見 `drafts/_meta/README.md`)適用於 **draft 存活期間**;
  封存是生命週期終點,搬移可接受,但 Phase 4 的引用修正**不可跳過**,不留斷鏈。
- 一次只封存一個 feature;要收多個就跑多次,不要批次混在一筆變更裡。
- Phase 2 的去向與上線 sprint **問使用者**,不要自行拍板;拿不到答案就寫 `TBD(規格未明)` 並在輸出提醒。
- 若該 feature 在 Gitea 上還有開著的 PR → 提醒使用者先處理完再封存。
- Phase 6 開 PR 是**送審**,不是上線;封存變更和其他規格變更一樣走 PR review 進 `main`。
- 開 PR 失敗(權限 / 網路 / tea 未設定)→ 保留已完成的 commit 與分支,顯示錯誤並建議跑 `/setup` 檢查,不要回滾封存。
