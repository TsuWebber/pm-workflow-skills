---
name: images-to-drive
description: 把 Notion 規格裡的圖片自動搬到 Google Drive，並在 markdown 裡換成可點的 Drive 連結——遵守 spec repo「圖片不進 repo」的鐵律。使用時機：從 Notion 匯入規格時圖片要落地（`from-notion` 會呼叫它），或手上一份 spec.md 的圖還躺在 Notion / 本機、要一次搬乾淨。觸發語如「把圖片上傳到 Drive」「這些圖幫我搬走」「圖片連結回填」「Notion 的圖怎麼辦」。不寫規格內文（那是 spec-write）。
---

# Images to Drive（Notion 圖片 → Google Drive → 只留連結）

## 定位

spec repo 有一條鐵律：**任何圖片 / 附件都不 commit**（見 `CLAUDE.md`）。
但 PM 的 Notion 規格裡圖很多——流程圖、單據影本、UI 截圖。這個 skill 就是那道閘門：

**Notion 圖片 → 下載 → 上傳 Drive → markdown 只留 `[標題](Drive URL)`。**

**核心設計：圖片位元組不經過 AI 的 context。**
下載與上傳全在 [upload.sh](./upload.sh) 裡完成，AI 只處理「檔名 ↔ URL」的對照表。
（若改用 Google Drive MCP 上傳，圖片得 base64 化後由模型逐字輸出當參數，一張截圖動輒數萬 token——那條路不可行，別走。）

**這個 skill 不做的事**：
- 不寫 / 不改規格內文（那是 `spec-write`）——它只動「圖片相關的那一行」。
- 不把圖 commit 進 repo，任何情況都不。
- 不決定圖要放哪一節——不確定就進 `actions.md` 問 PM。

---

## When To Use

適用：
- `from-notion` 搬遷途中，來源有圖 → **由 from-notion 在建完骨架後呼叫本 skill**
- spec 已經寫好，但圖還在 Notion / 只在本機 → 一次搬乾淨、回填連結
- `actions.md` 裡躺著「圖檔待上傳」的待辦，要清掉

不適用：
- 只是要在 spec 裡引用一張**已經在 Drive** 的圖 → 直接寫 `[標題](URL)` 就好，不必跑 skill
- 圖是 prototype 的產物（`drafts/<sprint>/<feature>/prototype/`）→ 那是程式碼不是圖，不歸這裡管

---

## Step 0：前置設定（rclone，代 PM 跑）

上傳靠 `rclone`——跨平台、單一執行檔、一次授權長期有效。
**這一段由你代跑,不要丟指令叫 PM 自己弄**；PM 只需要在瀏覽器點一次「允許」。

1. **檢查現況**：

   ```bash
   command -v rclone && rclone listremotes
   ```
   已經看到 `gdrive:` → 直接進 Step 1。

2. **沒裝就代裝**（先跟 PM 說一聲要裝什麼，再跑）：

   | 平台 | 安裝 |
   |---|---|
   | mac | `brew install rclone` |
   | Windows | `winget install Rclone.Rclone`（或 `scoop install rclone`） |

   *(Windows 上若 Claude Code 跑在 WSL，rclone 要裝在 WSL 裡,不是裝在 Windows 端。)*

3. **沒有 Drive remote 就代建**——用非互動指令，避免陷在 `rclone config` 的問答選單裡：

   ```bash
   rclone config create gdrive drive scope=drive
   ```
   這會**自動開瀏覽器**跳出 Google 授權頁。**先告訴 PM「等一下會跳出瀏覽器，請用公司帳號登入並按允許」**，
   他點完就結束，token 存進本機 `rclone.conf`，之後不必再授權。

   - 指令卡住不動 / 瀏覽器沒跳出來（常見於 SSH、無頭環境）→ 改跑 `rclone authorize drive`，
     把它印出的 token 貼進 `rclone config create gdrive drive scope=drive token='<貼上>'`。
   - remote 想取別的名字 → 跑腳本時設 `SPEC_REPO_RCLONE_REMOTE=<名稱>`。

4. 授權完驗一下：`rclone listremotes` 要看到 `gdrive:`。

5. 裝不了 / 公司電腦擋安裝 / PM 就是不想裝 → **退到 Plan B（見下方）**，不要硬上 MCP base64。

> ⚠️ **已知的定時炸彈**：上面的預設設定用的是 **rclone 共用的 Google client_id**，
> 每次跑都會跳警告說它「**will stop working during 2026**」。目前仍可用，
> 但哪天突然全部授權失效、或開始被限流，**第一個要懷疑的就是這件事**——不是腳本壞了。
> 屆時（或想提前免疫）：依 [rclone 官方說明](https://rclone.org/drive/#making-your-own-client-id)
> 申請一組自己的 client_id，重跑
> `rclone config update gdrive client_id=<ID> client_secret=<SECRET>` 再授權一次即可。

---

## Step 1：拿到目標 Drive 資料夾

**每個 feature 一個資料夾，由 PM 指定**（這是本 repo 的約定）。

跟 PM 要一個 Drive 資料夾連結，長這樣：
`https://drive.google.com/drive/folders/<FOLDER_ID>`

- PM 還沒開資料夾 → 請他在 Drive 開一個（建議命名 `<sprint>-<feature>`，如 `2609-monthly-billing-orders`）。
- 把這個連結記進該 feature 的 `spec.md` frontmatter `refs.drive`，下次要補圖不必再問。

### 權限（不可妥協）

規格圖裡常有**真實客戶資料、統編、印章、單據影本**。因此：

> **圖片絕對不能設成「知道連結的人都能看」（anyone with the link）。** 沒有例外、沒有「先這樣之後再改」。

- 可見範圍**由資料夾決定**：資料夾分享給**指定的人 / 指定的群組**（RD、QA、PM），圖上傳後自動繼承。
- 上傳腳本**只上傳、不碰分享設定**，也**不提供產生公開連結的選項**（傳 `--public` 會直接被擋下）。
- spec 裡放的是 `https://drive.google.com/file/d/<ID>/view`——**沒有權限的人點了會看到「需要存取權」,這是正確行為**，不是 bug。有人反映點不開 → 去 Drive 加他權限，**不要改成公開連結**。
- 開跑前先跟 PM 確認一句：**這個資料夾分享給誰?** 若他答「知道連結的都能看」→ 停下來，請他改成指定成員再繼續。

---

## Step 2：抽出圖片清單

從來源把圖找出來——來源有兩種：

**A. Notion 頁面**（主要路徑）
用 `notion-fetch` 讀頁面，markdown 裡的圖會長成 `![...](https://prod-files-secure.s3...)` 這種
**signed URL**。把它們**逐一抽出來**，同時記下每張圖**出現在哪一節 / 上下文寫什麼**——命名和回填都要靠它。

> signed URL **會過期（約 1 小時）**。抽完就馬上跑 Step 3，別中間插一堆討論；過期了就重抓一次頁面。

**B. 本機檔案**（PM 直接給一包圖）
直接用本機路徑當來源。

**命名規則**（要能一眼看出屬於誰、放哪節）：

```
<feature-slug>-<節次>-<序號>.<副檔名>
例：monthly-billing-orders-D3-01.png
    monthly-billing-orders-flow-02.png
```

節次判不出來 → 用 `misc`，並在 Step 5 列進待釐清問 PM。

---

## Step 3：跑上傳腳本

在 scratchpad（**不要在 repo 裡**）寫一份 manifest，每行 `檔名<TAB>來源`：

```
# manifest.tsv
monthly-billing-orders-D3-01.png	https://prod-files-secure.s3.us-west-2.amazonaws.com/...
monthly-billing-orders-flow-02.png	~/Downloads/export/flow.png
```

跑：

```bash
bash .claude/skills/images-to-drive/upload.sh \
  --folder "https://drive.google.com/drive/folders/<FOLDER_ID>" \
  --manifest <scratchpad>/manifest.tsv
```

輸出每行一筆，TAB 分隔：

```
OK	monthly-billing-orders-D3-01.png	https://drive.google.com/file/d/<ID>/view
FAIL	monthly-billing-orders-flow-02.png	下載失敗（signed URL 可能已過期，重抓一次 Notion 頁面）
```

- 全成功 exit 0；有任何一張失敗 exit 2（**不是崩潰，是要你去看 FAIL 那幾行**）。
- 腳本**只上傳、不碰任何分享設定**。圖的可見範圍完全繼承自 Step 1 那個資料夾——
  所以權限是在**開資料夾時**決定的，不是在上傳時。

---

## Step 4：回填 markdown

拿 `OK` 那幾行,回到 spec.md（或 meetings / decisions）把圖換成連結。

**寫法**（對齊 `CLAUDE.md` 的連結慣例——要能點，不是反引號路徑）：

```markdown
![流程圖](https://prod-files-secure.s3...)          ← 原本 Notion 的樣子
[D-3 頁首 ERP 狀態位置](https://drive.google.com/file/d/<ID>/view)   ← 換成這樣
```

- 連結**標題要有意義**（描述這張圖在說什麼），不要寫「圖片1」「image.png」。
- 圖放回**它原本所在的那一節**，不要全部堆到文末。
- 圖是規格的佐證、不是規格本身：**圖旁邊該有的文字描述不能省**——RD 不該為了懂一條規則去點圖。
  原 Notion 只有圖沒有文字 → 把圖的內容用文字補寫進 spec，並在 Step 5 請 PM 確認你讀對了。

---

## Step 5：收尾（失敗的、判不準的，一律留痕）

**不准默默丟掉任何一張圖。** 收尾做三件事：

1. **`FAIL` 的每一張** → 進 `actions.md`，寫清楚：哪張、為什麼失敗、誰要處理。
   ```markdown
   - 🟠 `monthly-billing-orders-flow-02.png` 上傳失敗（Notion signed URL 過期）
     → 重抓 Notion 頁面後重跑 `/images-to-drive`（負責人：@owner）
   ```
2. **節次判不準的** → 一併進 `actions.md`，列出「這張圖我不確定該掛哪一節」問 PM。
3. **清乾淨暫存**：scratchpad 的圖與 manifest 刪掉；跑一次 `git status` 確認**沒有任何圖片被 stage**。
   （`.gitignore` 已擋常見圖片副檔名，但別依賴它——自己確認。）

最後給 PM 一句摘要：**傳了幾張、進哪個 Drive 資料夾、回填了哪幾節、還剩幾張要處理。**

---

## Plan B：不裝 rclone 的話

PM 不想裝 rclone / 公司電腦裝不了 → 走 Notion 內建匯出，人工搬一段：

1. PM 在 Notion 該頁 `⋯` → **Export** → format 選 **Markdown & CSV**（或 HTML）→ 下載 zip。
   解開後圖片是**本機實體檔**（不會過期，比 signed URL 可靠）。
2. PM 把整包圖**手動拖進** Step 1 那個 Drive 資料夾。
3. 拖完後在 Drive 對每張圖「取得連結」，或直接把資料夾給我 —— 我用檔名對應，做 Step 4 的回填。

Plan B 的差別只有「上傳那一下由人做」，**命名、回填、留痕的規則完全一樣**，不要因為是人工就省掉 Step 5。

---

## Writing Rules

- 一律繁體中文；檔名、Drive 連結、指令保留英文。
- **圖片永不進 repo**——沒有例外。任何時候發現圖被 stage，停下來、移除、告訴 PM。
- **圖片永不公開分享**——沒有例外。不設「知道連結的人都能看」、不呼叫 `rclone link`、不因為「對方點不開」就放寬權限（正解是去 Drive 加人）。
- 圖片位元組**不進 AI context**：用 [upload.sh](./upload.sh)，不要用 MCP 上傳二進位。
- 失敗與不確定**一律進 `actions.md`**，不臆測、不默默跳過。
- 回填的連結一定要有**有意義的標題**（`CLAUDE.md`：不要貼裸 URL、不要用反引號包路徑）。
