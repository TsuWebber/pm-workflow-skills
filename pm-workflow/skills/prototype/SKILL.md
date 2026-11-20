---
name: prototype
description: 為 drafts 裡的某個 feature 做可在瀏覽器看的互動 prototype，視覺驗證 UI 流程；也能挑畫面問題（可用性 / 一致性）、部署到 Vercel 拿公開連結。檔案存進 drafts/<sprint>/<feature>/prototype/。使用時機：spec 規劃到一定程度想看畫面、或做好想挑問題 / 分享。觸發語如「做個 prototype」「讓我看畫面」「視覺化一下」「畫面有沒有問題」「哪裡看不懂」「幫我部署」「分享連結」「上線」。
---

# Prototype（產生 / 挑畫面 / 部署）

## 定位

把某個 feature 的規格 / 討論，快速變成可在瀏覽器看的 prototype，用來**視覺驗證**（不是完整實作、不串後端）。
三合一：**產生**畫面、**挑畫面問題**（可用性 / 一致性）、**部署** Vercel 拿公開連結。

檔案一律存進該 feature 的資料夾：`drafts/<sprint>/<feature>/prototype/`（一個 feature 一包）。

預設語言：繁體中文。

---

## 三種模式（依 PM 說的話判斷）

| 說什麼 | 模式 |
|---|---|
| 「做個 prototype」「讓我看畫面」「視覺化一下」 | **① 產生** |
| 「畫面有沒有問題」「哪裡看不懂」「幫我挑畫面」「review 一下」 | **② 挑畫面** |
| 「幫我部署」「分享連結」「上線」「發布」 | **③ 部署** |

先判斷是哪個模式，一句話說明理解再動手。

---

## When To Use / Not

適用：spec 規劃到一定程度想確認 UI 流程 / 版面；prototype 做好想挑問題或分享。

不適用（改用別的）：
- 要挑**規格邏輯**是否完整、缺漏 → `spec-review`（那是規格層，不是畫面層）
- 要產 AC → `spec-write`
- 要做完整前端開發 / 要 Figma 稿 → 不在此範疇

---

## 模式 ①：產生 prototype

**輸入來源**（依情境判斷，不夠再問 PM）：
1. 該 feature 的 `spec.md` / 對話中的規格討論
2. PM 直接口述的功能
3. （搬遷情境）Notion PRD —— 可讀來源，但**檔案只寫進 spec repo**

**技術格式判斷**（生成前說明選擇理由）：

| 情境 | 格式 |
|---|---|
| 靜態版面、純視覺、無複雜互動 | 純 HTML/CSS/JS（單一 `index.html` + Tailwind CDN） |
| 多步驟流程、需模擬狀態切換 | React + Vite（+ Tailwind CDN） |

**輸出位置**：
```
drafts/<sprint>/<feature>/prototype/
  index.html            ← HTML 格式
  # 或 React：index.html + src/ + package.json …
```
- feature 對齊資料夾名（kebab-case）。資料夾已存在 → 問是否覆蓋。
- **prototype 資料夾只放程式碼**；規格仍在同層 `spec.md`，不要把規格塞進 prototype 內。

**流程**：讀取核心操作路徑 → 說明格式選擇 + 列將建立的檔案 → 問「開始生成？」→ 生成 → 開瀏覽器並給連結。
- HTML：`open "<絕對路徑>/index.html"` + 對話給 `[在瀏覽器開啟](絕對路徑/index.html)`
- React：`cd drafts/<sprint>/<feature>/prototype && npm install && npm run dev` → 給 `http://localhost:5173`

**品質原則**：聚焦核心操作路徑（不覆蓋所有頁面）；用真實產品文案（非 Lorem ipsum）；假資料寫死在 JS，不串 API；乾淨好看。

---

## 模式 ②：挑畫面問題（可用性 / 一致性）

目標是找「使用者會停下來想、看不懂、或做錯」的地方 —— **不評估功能是否完整**（那是 `spec-review`）。

- **Mode A 純畫面**：對照 Nielsen 啟發式（系統狀態可見、一致性、認知優於記憶、可操作性提示、簡潔、錯誤預防）+ 產品內部一致性。
- **Mode B vs spec**：讀該 feature 的 `spec.md` 逐功能比對 —— spec 有定義但畫面沒做到、畫面做了但 spec 沒說、兩邊衝突。有 spec 時主動問要不要一起做。

**一致性檢查**（以 prototype 自身設計語言為準；下列為常見維度）：
- **顏色語意**：正向 / 警示 / 資訊 / 危險 各自固定一色，不混用。
- **數字格式**：金額帶單位（`NT$ X,XXX`）、百分比一位小數（`X.X%`）、趨勢帶 ▲▼、月數說明起算點。
- **術語一致**：同一概念全站同一個詞；縮寫要有中文標籤。
- **操作提示**：可點擊元件有 hover / 「點擊查看」；展開收合有符號（›、▼）。
- **空狀態**：用「XXX ✓」/「尚無 XXX」，不用 N/A 或空白。

**輸出**（對話報告，🟥🟨🟩）：
```
## 畫面 Review 摘要（整體清晰度 / 最易誤解處 / 優先改的方向）
## 1. 看不懂的地方   ### 🟥 高頻｜標題（位置 / 問題 / 一行建議）
## 2. 一致性問題     ### 🟨 中優先｜標題（位置 / 違反哪條規則 / 建議）
## 3. 操作動線問題
## 4. 數字缺乏上下文
## 5. 建議優先修改：🟥 / 🟨 / 🟩
```
🟥 高頻易誤解｜🟨 偶爾會停下來想｜🟩 細節優化。用業務員聽得懂的話，不用 UX 術語；一次最多 15 條，超過合併；不直接改 code。

> 挑到的**規格層**問題（不是畫面）→ 導去 `spec-review`；要改 spec → `spec-write`。

---

## 模式 ③：部署到 Vercel

1. **找 prototype**：
   ```bash
   find drafts -type f -name "index.html" -path "*/prototype/*" | sed 's|/index.html||' | sort
   ```
   只有一個 → 確認後部署；多個 → 列出讓 PM 選。
2. **部署**：`cd <資料夾> && vercel --prod 2>&1`。若回 `token is not valid` → 請 PM 在 Terminal 跑 `vercel login` 再回來。
3. **回連結 + 落地**：解析 `Production:` / `Aliased:` 的 URL，給可點擊連結（「連結永久有效，任何人可瀏覽」），並**寫回該 feature**：
   - `spec.md` §12 關聯表加一列 `| Prototype | <url> |`
   - `changelog.md` 補一筆：`<日期> prototype 部署 → <url>`（日期用當天實際日期）

---

## 落地與銜接

- prototype 是**丟棄式驗證material**，只放程式碼；build 產物（`node_modules/`、`dist/`、`.vercel/`）已被 `.gitignore` 排除，不進版控。
- 挑畫面 / 對照 spec 的結論要落實 → 用 `spec-write` 回改 `spec.md`。
- 要送出 drafts 變更（含 prototype 原始碼）→ `/ship`，PM 不用碰 git。

---

## Writing Rules

- 一律繁體中文，用產品 / 業務語言。
- 產生前一定先說明方案並等確認，不悶頭生成。
- 挑問題每條附一行具體改法；不直接改 prototype code。
- 跨檔引用用相對 markdown 連結（指到具體檔案，含 `.md`）；不要用 `[[...]]` wiki 連結，這個 repo 沒有會渲染它的靜態網站產生器。
