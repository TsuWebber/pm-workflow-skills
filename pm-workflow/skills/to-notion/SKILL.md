---
name: to-notion
description: 把 spec repo 裡的權威 spec 輸出成漂亮、可看出版本的 Notion 展示頁（供 PM 對外展示）。每個 feature 維護一個 Notion 活頁，重匯就地更新，頁內含版本徽章與「版本紀錄」表。使用時機：spec 寫得差不多、要在 Notion 給人看 / 展示 / 對外同步時。觸發語如「把這份 spec 輸出到 Notion」「發布成 Notion 展示頁」「同步到 Notion 給大家看」「更新 Notion 上那份」。這是單向輸出（spec repo → Notion），Notion 只是展示鏡像、不是來源。
---

# To Notion（把 spec 輸出成 Notion 展示頁）

## 定位

PM 習慣在 Notion 展示頁面。這個 skill 把 `drafts/<sprint>/<feature>/spec.md` 輸出成一份
**漂亮、可看出版本**的 Notion 頁，供對外展示 / 給非 spec repo 使用者看。

它是 `from-notion` 的**反方向**：

| skill | 方向 | 性質 |
|---|---|---|
| `from-notion` | Notion → drafts | 匯入(Notion 唯讀來源) |
| **`to-notion`** | **drafts → Notion** | **輸出(Notion 唯讀鏡像)** |

**最重要的界線 —— 權威版永遠在 spec repo（git），Notion 只是展示鏡像：**
- 每頁頂端固定放一條 🔒 banner：「本頁由 spec repo 自動輸出,**請勿在此編輯**;權威版見 \<Gitea 連結\>」。
- **絕不把 Notion 上的改動讀回來**(那是污染來源)。要改規格 → 改 spec repo 的 spec.md → 重新輸出。

預設語言：繁體中文（技術名詞、欄位名、狀態 enum、API path 保留英文）。

---

## When To Use

適用：
- spec 寫得差不多，要在 Notion 給人看 / 展示 / 對外同步
- 「輸出到 Notion」「發布成 Notion 展示頁」「更新 Notion 上那份」

不適用（改用別的）：
- 要把 Notion 規格搬**進** spec repo → `from-notion`
- 還沒寫好 spec → `spec-write`
- 只想在 spec repo 內挑問題 → `spec-review`

> **展示鏡像不是送審**。對內的 review / 合併走 `/ship`(Gitea PR);Notion 頁只給看。

---

## Step 0：token 成本確認（先估、先跟 PM 確認）

> **開跑前必做，不可略過。** 這個 skill 會**讀 spec.md + changelog + 組整頁版面 + 寫 Notion + 回讀校正**，是**高 token 消耗**操作，動輒是一般問答的數倍;重匯還要覆蓋整頁。務必先讓 PM 知道成本、確認要跑再開始。

1. **先粗估規模**（不必精準，給 PM 一個量級感）：
   - 看 spec.md 有多長（12 節填了多少、有無大表格 / 多個 AC Scenario）。
   - 給一句白話估算，例如：「這份 spec 蠻完整的，輸出到 Notion 大概會用掉**不少** token（含組版與回讀校正）」。
2. **明確請 PM 確認**：一句話說明「這一步比較燒 token，要我現在輸出嗎？」等 PM 回「好 / 開始 / 確認」再進 Step 1。
3. PM 若想省：建議**改到差不多再一次輸出**，不要每改一點就重匯（Notion 是展示鏡像，不必即時同步）。
4. 已在同一輪對話明確說過「直接輸出 / 別再問」→ 可不重複確認，但**仍要一句提示成本**。

---

## Step 1：定位 feature、載入內容

1. **定位** `drafts/<sprint>/<feature>/`（PM 沒指定就問是哪個 feature / sprint）。
2. **讀三處**：
   - `spec.md` —— 主體內容 + frontmatter（`title` / `sprint` / `spec_version` / `owners` / `refs`）。
   - `changelog.md` —— 用來生「版本紀錄」表。
   - frontmatter 的 `refs.notion_export` —— 若已有值，表示這個 feature 之前匯出過，這次是**就地更新**。
3. 取一個 **Gitea 權威連結**（spec.md 在 repo 的路徑）備用，放進頁頂 banner。
   - **一律指向 `main` 分支**（權威版最終落點）：
     `https://<GIT_HOST>/<ORG>/<SPEC_REPO>/src/branch/main/<path-to-file>`
     例：`.../src/branch/main/drafts/2606/product-master/spec.md`。
   - **不要指向 draft 功能分支**（例 `drafts/2606-product-master`）：① 分支合併後會刪除 → 死連結;
     ② 分支名含 `/` 會讓 Gitea 的 `/src/branch/<ref>/<path>` 無法切分 ref 與路徑而失效。
   - 同一組 `main` 路徑也用在內文所有跨檔引用（`decisions.md` / `actions.md` / `changelog.md` / `reference/*`）。

---

## Step 2：決定目標 Notion 頁

- **已匯出過**（`refs.notion_export` 有值）→ 用該頁 id **就地更新**（`notion-update-page`），連結不變。
- **首次匯出**（沒有值）→ 需要一個**母頁**：
  1. 若 repo 有記錄預設母頁（見下「母頁設定」）→ 用它。
  2. 沒有 → 問 PM 要一個 Notion 母頁連結,在其底下 `notion-create-pages` 建一個**子頁**（標題＝feature 顯示名）。
  3. 建好後把新頁 URL **寫回 spec.md 的 `refs.notion_export`**（讓下次能更新同一頁）。

> **母頁設定**：整個 repo 共用一個輸出母頁時，可把它記在 `drafts/_meta/` 的設定備忘，避免每次問。
> 這是唯一寫回 spec repo frontmatter 的動作(記錄「輸出到哪」),**不是**回寫 Notion 來源。

---

## Step 3：組版面（漂亮、可看出版本）

把 spec.md 轉成 Notion blocks，套固定版面：

```
🔒 [banner callout] 展示鏡像,請勿在此編輯 → <Gitea 權威連結>
📘 [header callout]
   <功能名> · sprint <x> · spec_version <v> · 匯出於 <日期>
   owners: <...>
[/toc 目錄]
──────────
## 1. Goal & Success Criteria
…（12 節，順序照鎖定模板）
──────────
## 版本紀錄
[表] 日期 | 版本 | 改了什麼 | BE / FE / QA 注意   ← 鏡像 changelog.md
```

轉換規則：
- **表格** → Notion 原生表格；**AC 的 Scenario（S1、S2…）** → 每個一個 toggle（收合 Given/When/Then，展示頁乾淨）。
- **`🔴 / 🟠 / ⚪`** 待釐清燈號原樣保留。
- **指向 repo 內其他規格的相對連結**（含舊文件殘留的 `[[...]]`）→ Notion 沒有對應頁，轉成**指回 Gitea `main` 路徑的完整連結**（見 Step 1.3），不留死連結。
- **`（無）`** 的空章節照留，維持 12 節完整骨架。
- 匯出日期用**使用者提供的當天日期**，不自行捏造。

> ⚠️ **Notion 會自動把「看起來像網域的裸文字」變成死連結**（例 `actions.md`、`decisions.md`、`brand.com` → `http://actions.md`）。因此：
> - **每個跨檔 `.md` 引用都要寫成完整連結** `[actions.md](https://<GIT_HOST>/.../src/branch/main/.../actions.md)`，**絕不留裸檔名**——包含表格儲存格與 header callout 內。
> - **不是連結、但長得像網域的字**（例 `brand.com`、`xxx.md` 純提及）→ 包成 inline code `` `brand.com` `` 擋掉自動連結。
> - 輸出後**回讀該頁一次**，掃有沒有冒出 `http://...md` / `http://<字>.com` 這種自動連結，有就補成正確連結或 inline code。

---

## Step 4：寫出 + 回報

1. 依 Step 2 **建立或就地更新**該 Notion 頁。
2. **就地更新**時：整頁內容以最新 spec 覆蓋（含版本紀錄表）—— 讀者永遠看到最新版 + 完整版本軌跡。
3. **回報**：Notion 頁連結、這次輸出的 `spec_version`、是「新建」還是「更新」。

---

## Step 5：收尾

- 提醒：**這是展示鏡像**，之後 spec 一改，要再跑一次 `to-notion` 才會同步（Notion 不會自己更新）。
- 若 PM 想讓某版「定住給人看」→ 說明目前是單一活頁模型（永遠顯示最新版 + 版本紀錄）；要保存特定版快照是另一種模式，需另議。

---

## Writing Rules

- 一律繁體中文，用產品語言。
- **單向輸出**：只從 spec repo 讀、往 Notion 寫；**絕不把 Notion 的改動讀回 spec**。
- 頁頂 banner 與 header 徽章**每次都要有**，這是「看出版本 / 知道權威在哪」的關鍵。
- 只輸出 `spec.md` 主體 + 版本紀錄；`decisions.md` / `actions.md` 用連結帶到，不整包塞。
- 版面順序照鎖定 12 節模板,不重排。
- 日期用使用者提供的當天日期,不自行捏造。
