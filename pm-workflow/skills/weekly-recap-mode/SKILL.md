---
name: weekly-recap-mode
description: Generate a two-version personal weekly recap in Traditional Chinese (結果版 + 個人紀錄版) from a Squad weekly note URL (extracts the user's Owner Update toggle) plus last week's Google Calendar events and the user's personal Task database. Personal version is a day-by-day journal with retrospective reflection. Always shows both drafts in chat first; user decides distribution and writeback.
---

# Weekly Recap Mode

## Overview

把「Squad 共同週報中 使用者的 Owner Update + 上週工作日的 Calendar 事件 + 個人 Task DB」整理成兩個受眾版本的個人週報草稿。

預設輸入:
- 一個 Squad 共同週報 Notion 頁面 URL(固定,見 Inputs)
- 上週一到週五的 Google Calendar 事件(由 skill 自動抓並過濾)
- 上週一到週五的個人 Task DB 項目(由 skill 自動抓)

預設輸出語言:繁體中文。
預設輸出位置:**對話框中**。兩個版本同時呈現,不自動寫入 Notion,不自動發送。

兩個版本的設計哲學:
- 結果版 → 給高層的 30 秒快速更新,結果導向
- 個人紀錄版 → **日記式時間軸 + 複盤反思**,以利自己迭代

(已不再產出「週報版」狀態 × 產品線矩陣。)

---

## When To Use

適用情境:
- 使用者說「幫我寫週報」、「整理上週工作」、「跑 weekly recap」
- 使用者貼了一個 Squad 共同週報頁面 URL,並要求總結
- 週五下午要準備發給 主管 / Squad / 其他受眾的進度更新

不適用情境:
- 使用者要寫 PRD → 使用 `spec-write`
- 使用者要寫 release note → 使用 `pm release`
- 使用者要寫月報、季度自評(範圍超過一週,需要不同處理)
- 使用者只要單純摘要 Calendar,不需要兩版本格式

---

## Inputs

### Required
- **Squad 共同週報 Notion 頁面 URL**:預設固定為 `https://www.notion.so/<PAGE_ID>/PM-weekly-update-<NOTION_ID>?source=copy_link`(來源於 weekly update database `<NOTION_ID>`,包含 🧭 Summary 與 👤 Owner Update 區塊)。**不需要每次詢問使用者**,除非使用者另外指定其他 URL。

### Auto-fetched
- **Google Calendar 事件**:上週一 00:00 到上週五 23:59 之間的所有事件
  - 用顏色 + 事件名稱過濾(見下方 Calendar Filtering Rules)
  - 計算「上週」基準:今天往前推到最近的週一作為本週起點,再往前推一週的週一到週五
  - 主要用途:抓🔵會議時段(在 Calendar 上通常沒有綠色色塊)
- **個人 Task database**(Notion,`collection://<NOTION_DB_ID>`,頁面 `https://www.notion.so/<PAGE_ID>/<NOTION_ID>`):使用者 用來時間блок排程實際工作項目的資料庫,欄位含 `Do Date`(時間區段)、`Name`、`Status`、`Product`、`Priority`、`Sprint`
  - 查詢條件:`date("date:Do Date:start") BETWEEN 上週一 AND 上週五`
  - **時間為 UTC**,顯示/計算前需 +8 小時轉換為台北時間
  - 這是 **🟢 Sprint 工作** 時數的主要來源(取代 Calendar 綠色色塊,因為 使用者 實務上不太用 Calendar 記工作時段,而是用這個 Task DB)
  - `Product` 欄位對應到 Product Line Taxonomy 做分類(例:2C 銷退／月結銷退／外部商城託運單上傳 → Process)
  - Status 為 `Abandon` 的項目仍計入時數,但個人紀錄版標記說明(該任務後來放棄)
  - **標籤與名稱明顯不符時**(例如 Product 標「推薦商品」但名稱是庫存工具):先依名稱暫時歸類,紀錄中註明「標籤為 X,依名稱歸類」,並在輸出後**提醒 使用者 回 Task DB 修正標籤**,列出項目名稱、日期與建議的正確 Product。不要自行改 DB

### Interactive(由 skill 主動詢問)
- **本週做得好的**:由使用者口述,skill 在 Step 5 詢問
- **本週待改進的**:由使用者口述,skill 在 Step 5 詢問

---

## Calendar Filtering Rules

### 顏色規則(colorId 對應)

Google Calendar API 的 colorId 對應 使用者的使用習慣:

- **🔵 藍色 = 會議**
  - colorId `9` (Blueberry)、`7` (Peacock)、**或無 colorId（default，繼承 Calendar 底色）**
  - 使用者的 Calendar 底色為藍綠（Peacock），受邀會議通常無 colorId，API 回傳 `default`，視同 🔵
  - 個人紀錄版:列在當天時間軸中,前綴 🔵
  - 結果版:轉化為「對齊結論 / 進度推進」,不直接寫會議名

- **🟢 綠色 = 工作內容**
  - colorId `10` (Basil) 或 `2` (Sage)
  - 個人紀錄版:列在當天時間軸中,前綴 🟢
  - 結果版:作為素材,轉化為結果語

- **其他顏色（非 default、非綠）**
  - 例如 colorId `11`（Tomato 紅）等,前綴 🔴,列入時間軸但不計入 🔵/🟢 時數,歸 🔥 其他破事

### 過濾規則(事件名稱)

以下事件**不寫進任何版本**(無論顏色為何):

- `Daily`
- `Daily Squad - Team A`
- `Daily Squad - Team B`
- `Daily Squad - Tech Team`
- `SPRINT END` / 含 "Sprint End" 的事件
- `OOO` / 含 "OOO" 的事件
- 含「檔期活動」、「檔期」的事件
- 純資訊性 review、純資訊同步會議
- **全天橫幅事件**(Release、會員日、雙十一/檔期、Sprint Start / Beta Ready 等):一律排除,不進任何版本
- **私人事項**(例如「約」、「拿東西給…」這類非工作行程):排除;不確定是不是私人事項時,輸出後用選擇題問
- **休假日會議**:Calendar 上有 使用者 自己的 [OOO](全天或半天)時,該時段的會議視為沒開,不計入;Task DB 在休假期間仍有項目的,照常保留並在紀錄標「休假中小加班」

事件名稱比對採模糊比對(包含即過濾)。

### 過濾後處理

- 過濾後若 Calendar 沒留下任何有效事件,跳過 Calendar 整合,只用 Notion 產出
- 個人紀錄版需要「按天分組」,所以保留每筆事件的日期/時間資訊

### 時間比例計算規則

過濾後,對所有有效事件依下列規則分類並計算時數:

**分類定義:**

- **🔵 會議**:Calendar 事件中,colorId 為藍色(9 Blueberry / 7 Peacock)的事件,或無 colorId（default）的事件
- **🟢 Sprint 工作**:主要來源是**個人 Task database**(Do Date 落在上週的項目,依 Product 欄位對應產品線),而非 Calendar 綠色事件(使用者 實務上很少用 Calendar 標綠色工作區塊)。若 Calendar 上仍出現 colorId 10/2 的綠色事件,且能語意對應 Notion Owner Update 計畫項目,一併併入此類並避免與 Task DB 重複計算同一時段
- **🔥 其他破事**:Calendar 上其他顏色(非 default、非藍、非綠)的事件,以及無法語意對應到任何計畫項目的臨時事項

**時數計算方式:**
- 用每筆事件的起訖時間計算持續時長(小時,取一位小數)
- 加總三類各自的總時數
- 計算各類佔總時數的百分比(四捨五入到整數)
- 若事件無起訖時間(全天事件),視為 0 小時,不計入比例

**對應判斷原則:**
- 能對應 = 事件名稱/描述與 Notion Owner Update 中某個工作項的產品線、功能名稱有**語意重疊**（不要求字面完全相同）
- 例:Calendar「轉換數據指標追蹤」= Notion「埋點文件」→ 視為對應；Calendar「新加坡蝦皮」= Notion「新加坡蝦皮 API 串接」→ 視為對應
- 優先做語意推論，只有確實無法推論時才標 ⚠️ 歸入「🔥 其他破事」

---

## Product Line Taxonomy

使用者的工作以下列產品線分類,用於 🟢 Sprint 工作時數的產品線分解與工作項歸屬判斷(結果版不分產品線):

- **Process** — 流程、單據優化、調撥、庫存、補出貨、對帳
- **AI** — AI 下單助手、prompt 調整等
- **Data** — CDP(Phase 1-1 / 1-2)、會員標籤、DB 串接、資料品質問題
- **2C** — 消費端產品
- **2R** — 經銷端產品(月結通路、非月結通路、直營通路為 2B 下的渠道;但「直營通路需求」屬非月結銷退流程,工作項歸 Process)
- **CMS** — 內容與商品管理:頁面管理、Menu、商品推薦、Blog、Media Library、站台設定、SEO、Product Feed、商品主檔(Task DB `Product` 為「推薦商品」的項目歸此)
- **Others** — User Guide、埋點、數據工具通報、跨部門通報、Q2/季度規劃、文件等

判斷工作項歸屬時:
- 看主要影響的系統 / 使用單位
- 對帳、補出貨歸 Process
- CDP 一律歸 Data
- CMS 相關工作一律歸 CMS,不再歸 2C
- 跨產品線的工作放在主要負責的那條,不重複列

---

## Workflow

### Step 1:確認輸入

Squad 週報 URL 使用上方 Inputs 區塊的預設固定 URL,**不需要詢問使用者**。只在使用者明確給了不同的 URL 時才改用該 URL。

向使用者確認:
- 是否要納入 Calendar(預設「是」,使用者說不用就跳過)

### Step 2:讀取資料

並行執行:
- 用 `notion-fetch` 讀取 Squad 共同週報頁面
- 用 `Google Calendar:list_events` 列出上週一到上週五的事件
- 用 `notion-query-data-sources` 查詢個人 Task database,條件為 `Do Date` 落在上週一到上週五(記得 UTC+8 轉換)

#### 從 Squad 週報抓取 使用者的內容

抓取規則:
- **主要素材**:使用者 toggle 內的狀態區塊(✅ 本週完成 / 🛠️ 本週推進中 / ⚠️ 延期 / ⏭️ 下週)
- **輔助素材**:Summary 區塊裡跟 使用者 負責產品線重疊的部分(主要是 Data,因為 CDP 是 使用者 主責)
- **不抓**:其他成員的 Owner Update 區塊

#### Calendar 過濾與分組

依 Calendar Filtering Rules 過濾事件後:
- 按日期分組(D1 週一 / D2 週二 / D3 週三 / D4 週四 / D5 週五)
- 每天再分 🔵 會議 / 🟢 工作事項
- 保留時間資訊(供個人紀錄版使用)
- **同步進行時間比例分類**:依「時間比例計算規則」對每筆事件分類(會議 / Sprint 工作 / 其他破事),記錄各類總時數,供 Step 6 個人紀錄版輸出

### Step 3:資料摘要與確認

讀完後在對話中**簡短摘要**:
- 使用者 toggle 抓到幾項(分各狀態)
- Calendar 過濾後留下幾筆,按天分布大概是多少
- **時間比例初步計算**:會議 X 小時 / Sprint 工作 Y 小時 / 其他破事 Z 小時,各佔 N%
- 若有無法判斷歸類的事件,列出並請使用者確認屬 Sprint 還是破事
- 若有衝突或落差,點出來讓使用者確認

**不停下來等確認**,直接進入 Step 4 並產出兩個版本(用預設值處理有疑問的項目)。需要使用者決定的事項,在輸出完成後用 `AskUserQuestion` 選擇題一次問完,不要用開放式問句。

### Step 4:整合與分類

把 使用者 Owner Update + 過濾後 Calendar + Task DB 整合:

**結果版**(維度:最高優先級的結果)
- Notion Owner Update 為基準骨架
- Task DB / Calendar 補強內容
- Notion 與 Calendar 衝突時,信 Notion

**個人紀錄版**(維度:時間軸)
- 以 Calendar(🔵會議/🔥其他)+ 個人 Task DB(🟢 Sprint 工作)合併為主骨架(D1–D5),依時間排序混排
- Notion 內容作為工作項描述的補充語意(例如把 Task DB 的項目對應回 Notion 的哪個計畫)
- 若無法判斷時間,放在週末總結或不放
- 保留會議與工作事項的順序與時間
- Task DB 項目時間為 UTC,需 +8 小時換算為台北時間再排入時間軸

### Step 5:詢問複盤問題

**這是個人紀錄版專屬的互動步驟。**

預設**不先停下來問**:使用者已提供複盤就整理進去;沒提供就先放 `- (暫無)`,輸出後再邀請補上。邀請時的問法:

> 在產出個人紀錄版前,想請你回顧一下:
>
> 1. **本週你覺得做得好的事情有哪些?**(可以是工作產出、決策、溝通、學習等)
> 2. **本週有哪些是你覺得待改進、下次想調整的?**(卡點、遺漏、節奏問題、跟人協作的摩擦等)
>
> 你可以條列幾個,也可以隨意說,我會整理進個人紀錄版。如果暫時想不到、想跳過,直接說「跳過」就好。

收到回應後:
- 將「做得好的」與「待改進的」整理成精簡 bullet,放進個人紀錄版開頭
- 若使用者跳過,該區段留空 placeholder(`- (暫無)`)讓未來自己回填

互動處理規則:
- 不要追問太多,使用者一次回答後就接續產出
- 若使用者回答得很簡短(例如「沒什麼特別的」),不要硬擠,照寫一兩條精簡內容
- 若使用者明確說「先給我看 Calendar 抓到什麼再決定」,可以先輸出 Step 3 的摘要再問

### Step 6:產出兩個版本

依下方 Output Structure 一次輸出兩個版本,全部呈現在對話中。
兩版本之間用清楚的分隔線與標題區分,方便使用者複製。

### Step 7:等待使用者決定

不主動建議發給誰、不主動寫回 Notion。
使用者看完後可能會說:
- 「結果版發給 主管」→ 維持輸出,不執行其他動作
- 「個人版寫進 weekly updates DB」→ 此時才寫入 Notion(`<NOTION_ID>`)
- 「結果版重寫,加上 CDP 進度的業務影響」→ 修改後重新呈現

只在使用者明確要求時才執行寫入或修改。

---

## Output Structure

兩個版本依序輸出,標題清楚分隔。

### 版本一:結果版(30 秒讀完)

給高層或 1:1 用,聚焦個人最高優先級產出。

```
# 📋 結果版 | Week of [日期區間]

- [重點 1:結果導向,一句話帶出影響]
- [重點 2]
- [重點 3]
- [重點 4]
```

規則:
- 4 條為主,最多 5 條
- 每條一句話,不換行不縮排
- 寫「完成什麼 + 帶來什麼結果」,不寫「做了什麼動作」
- 只放本週個人最高優先級的 4 件事
- 風險只放會影響交付的,不放例行性
- 不分產品線,直接列重點

### 版本二:個人紀錄版(日記式時間軸 + 複盤反思)

寫給未來的自己,可寫進私人 weekly updates DB。
**結構:複盤反思在前,時間軸紀錄在後**。

```
# 📝 個人紀錄版 | Week of [日期區間]

## 做得好的
- [使用者回答整理成的 bullet]
- ...

## 待改進的
- [使用者回答整理成的 bullet]
- ...

## ⏱️ 本週時間分配
總有效工時:[X] 小時

| 類型 | 時數 | 比例 |
|------|------|------|
| 🔵 會議 | X.X hr | XX% |
| 🟢 Sprint 工作 | X.X hr | XX% |
| 🔥 其他破事 | X.X hr | XX% |

> [若有 ⚠️ 無法確定歸類的事件,在此說明並標記]

## 紀錄

- D1(週一 MM/DD)
    - 🔵 [HH:MM - HH:MM] [會議名] | 與 [人] | [結論或目的]
    - 🟢 [HH:MM - HH:MM] [工作項] | [產品線標籤,選填]
    - 🔥 [HH:MM - HH:MM] [其他事項]
    - ...（依時間由上到下混排，不分子區塊）
- D2(週二 MM/DD)
    - ...
- D3(週三 MM/DD)
    - ...
- D4(週四 MM/DD)
    - ...
- D5(週五 MM/DD)
    - ...
```

規則:
- **「做得好的」與「待改進的」放最前面**,因為這是複盤的核心
- 五天都要列出(D1–D5),即使某天沒有事件也保留標題,內容寫 `- (無紀錄)`
- 每筆紀錄保留時間 `[HH:MM - HH:MM]`(起訖時間),讓使用者重建當天的節奏感
- **日內事件依時間順序混排**，每筆前綴對應 emoji（不分 🔵/🟢 子區塊）：
  - 🔵 `[HH:MM - HH:MM] 會議名 | 與 [人] | [結論或目的]`
  - 🟢 `[HH:MM - HH:MM] 工作項 | [產品線標籤,選填]`
  - 🔥 `[HH:MM - HH:MM] 其他事項`
  - 🔴 `[HH:MM - HH:MM] 特殊顏色事件 | ⚠️ 目的不明`
- 不需要再額外做 Done / Blockers / Next Week 分區
- 若使用者請求補充某天的細節(例:某個會議發生了什麼),可在當筆下加縮排說明

---

## Writing Rules

- 一律使用繁體中文
- 兩個版本的「同一件事」用詞要一致(專案名、人名、模組名)
- Calendar 🔵 會議在結果版要轉化,在個人紀錄版照實列出
- Calendar 🟢 工作項在個人紀錄版要保留時間,在結果版轉化為結果語
- 不確定的人名、deadline 標 ⚠️,不要瞎填
- 結果版不寫風險細節,只寫到「有/沒有需要 escalate 的風險」
- 個人紀錄版的「做得好/待改進」要忠實反映使用者的回答,不要過度解讀或加料
- 工作項描述用結果性語言,不寫過程

---

## Section Rules

### 結果版
- 開場不要 callout、不要前言,直接 4 條 bullets
- 每條開頭用動詞或結果名詞,不用「我」開頭
- 若有重大風險,在第 4 條提到

### 個人紀錄版 - 做得好 / 待改進
- 由 Step 5 的互動取得,不要自己編
- 整理成精簡 bullet,每條一句話
- 不評論、不延伸建議,使用者怎麼說就怎麼寫
- 若使用者跳過,寫 `- (暫無)`

### 個人紀錄版 - ⏱️ 時間分配區塊
- 位置:「待改進的」之後、「紀錄」之前
- 總有效工時 = 三類時數加總(不含全天事件)
- **主表格**三行固定:🔵 會議 / 🟢 Sprint 工作 / 🔥 其他破事
- 百分比四捨五入到整數,三項加總允許因四捨五入誤差 ±1%
- 若有 ⚠️ 無法確認歸類的事件,在表格下方用 `>` blockquote 標出,請使用者確認
- 若 Calendar 無有效時數,整個區塊寫 `(無有效 Calendar 時數,無法計算)`
- **主表格之後，緊接輸出 🟢 Sprint 工作產品線分解子表格**：

  | 產品線 | 時數 | 佔 Sprint % |
  |--------|------|-------------|
  | Process | X.X hr | XX% |
  | AI | X.X hr | XX% |
  | Data | X.X hr | XX% |
  | 2C | X.X hr | XX% |
  | 2R | X.X hr | XX% |
  | CMS | X.X hr | XX% |
  | Others | X.X hr | XX% |

  - 只列時數 > 0 的產品線
  - 比例為該產品線佔「🟢 Sprint 工作總時數」的百分比
  - 產品線歸屬判斷依 Product Line Taxonomy

- 時間格式統一:`[HH:MM - HH:MM]`(24 小時制,起訖時間)
- 過濾掉的事件(Daily、SPRINT END 等)不出現

---

## Behavior When Information Is Missing

- 使用者 toggle 內容很少:照樣產出兩版本,空欄位標 ⚠️,並提示「Squad 週報 使用者 區塊紀錄不足,以下版本主要依賴 Calendar / Task DB 補強,請確認」
- Calendar 抓不到事件 / 過濾後全空:個人紀錄版的時間軸區塊每天寫 `- (無紀錄)`,提示使用者「Calendar 過濾後無事件,個人紀錄版時間軸無內容,建議檢查顏色標記」
- 使用者跳過複盤問題:個人紀錄版「做得好/待改進」區塊寫 `- (暫無)`,其他正常產出
- 工作項無法判斷產品線歸屬:歸 Others,個人紀錄版可省略產品線標籤
- Squad 週報 URL 抓到的不是預期格式(沒有 Owner Update 區塊):提示使用者 URL 可能錯誤,請確認

---

## Notion Writeback(僅在使用者明確要求時)

若使用者說「個人版寫進 weekly updates DB」或類似指令:
- 寫入 weekly updates database(`<NOTION_ID>`)
- 標題格式:`YYYY/MM/DD`(對齊既有頁面命名,例:`2026/4/24`)
- 內容:個人紀錄版完整內容
- 寫入後在對話中回報:「已寫入 weekly updates DB,連結:[URL]」

skill **不直接編輯 Squad 共同週報頁面**(別人也會編輯的共用頁)。

---

## End Condition

兩個版本輸出完成後,等待使用者決定後續動作。
- 不主動詢問「要不要寫進 Notion」
- 不主動建議「這版發給誰」
- 使用者明確指示後才執行寫入、複製、調整
