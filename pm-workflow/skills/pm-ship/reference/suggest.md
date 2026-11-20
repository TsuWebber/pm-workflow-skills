# PR Suggest（在 PR 上留建議修改）

## 定位

Gitea 原生不能套用建議；公司的 Gitea 裝了 needle，會在 ```suggestion 留言上加一顆「套用」，
按下去就**用區塊內容取代被留言的那一行**並提交 commit。這個 skill 讓 AI 產出的留言
每一則都能被一鍵套用：行號落點對、內容是整行改寫後的全文。

建議只是留言，送出後由 PR 作者決定套不套用。這個 skill 不改檔案、不 commit。

---

## 一則建議的形狀

needle 套用時做的事是：取留言掛的那一行（新版行號 N），把它換成區塊裡的所有行。由此推出四條規則：

- **一則建議 = 一個目標行**：要改連續三行，就拆成三則，各掛在自己那一行。
  把三行寫進同一個區塊，只會取代第一行，另外兩行原封不動留著，內容重複。
- **區塊內容是整行的最終全文**：保留 markdown 前綴與結構，像 `- `、`## `、表格的 `| … |` 與欄數。
- **拆成多行可以**：區塊寫兩行，就是把一行換成兩行（例如補一個條列項目）。
- **刪除整行做不到**：空區塊會把那一行換成空白行。要刪就用一般留言說明。

內文格式：一句理由、原文標記、建議區塊，依序排列。

````markdown
取消時限要跟補償流程的 SLA 對齊。
<!-- original: 訂單成立後 60 分鐘內可以取消，逾時請聯繫客服，並改走補償流程。 -->
```suggestion
訂單成立後 45 分鐘內可以取消，逾時請聯繫客服，並改走補償流程。
```
````

- **原文標記**：`<!-- original: <第 N 行原文> -->` 照抄目標行全文。Gitea 渲染時會隱藏它，
  `pm-ship apply` 靠它核對分支後來有沒有改動那一行。
- 目標行本身含 ``` 時，外層改用四個反引號 ````` ````suggestion `````。

### 目標行在 diff 區段外時

「檔案變動」頁只顯示 diff 區段，其餘的行收起來。掛在收起行上的留言，要等讀者點區段旁的
展開箭頭才會出現，展開後一樣有套用按鈕。所以區段外的行也能留建議，但理由前面要加一句提示：

```markdown
（第 N 行在收起的區段裡，請在檔案變動頁點開第 N 行附近的展開箭頭。）
```

「對話內容」頁籤會照常列出這則留言，作者看得到，但要回檔案變動頁才能套用。

---

## 步驟

### 1. 取得 PR 與憑證

- PR 編號由使用者提供；沒給就列出開著的 PR 請使用者選。
- 憑證沿用 [`pm-ship（開 PR 步驟）`](pr.md) 第 5 步的路徑 2 或 3（`GITEA_TOKEN`，或從 `git credential fill` 取帳密）。
  以下用 `$AUTH` 代表 curl 的認證參數（`-H "Authorization: token $GITEA_TOKEN"` 或 `-u "$U:$P"`），
  `$API` 代表 `https://<GIT_HOST>/api/v1/repos/<ORG>/<SPEC_REPO>`。
  **絕不印出密碼或 token**。
- 取 PR 資訊：`GET $API/pulls/<n>`，記下 `head.sha` 與 `user.login`。
- 取 diff：`GET $API/pulls/<n>.diff`。

完成條件：手上有 `head.sha` 和完整 diff。

### 2. 檢查草稿留言（必做）

`GET $API/pulls/<n>/reviews`，找 `state` 為 `PENDING` 且 `user.login` 是憑證本人的 review。

用 API 送出 review 時，Gitea 會把本人所有**還沒送出的草稿留言**一起發佈出去。
有草稿就停下來告訴使用者，請他先在網頁上送出或刪掉，再繼續。

完成條件：本人沒有 `PENDING` 的 review。

### 3. 挑出目標行並核對原文

每一則建議都要過這三關：

1. **行號是新版行號**：從 diff 的區段標頭 `@@ -a,b +c,d @@` 往下數，`+` 行與空白開頭的上下文行
   各佔一個新版行號，`-` 行不佔。
2. **標出區段外的行**：目標不在任何區段內（不是 `+` 行也不是上下文行）時，
   內文要加上一節「目標行在 diff 區段外時」的提示。`-` 行不能當目標。
3. **原文核對**：`GET $API/raw/<path>?ref=<head.sha>`，確認第 N 行就是你要改的那一行。

完成條件：每則建議都有 `path`、新版行號 N、第 N 行原文、改寫後全文，以及「區段內 / 區段外」的標記。

### 4. 給使用者確認

送出是對外的動作，留言會通知 PR 作者。先列出清單：

```
PR #<n>，共 K 則建議：
1. <path>:<N>（區段內 / 區段外）
   原文：<第 N 行原文>
   建議：<改寫後全文>
   理由：<一句話>
```

使用者確認（或刪改）後才送出。

### 5. 送出

一次送一個 review，所有建議放在同一個 `comments` 陣列。用 `jq` 組 JSON，避免中文與換行的跳脫問題：

```bash
jq -n --arg sha "<head.sha>" --slurpfile c comments.json \
  '{event:"COMMENT", body:"<一句總結>", commit_id:$sha, comments:$c[0]}' > review.json
curl -s $AUTH -H "Content-Type: application/json" -d @review.json "$API/pulls/<n>/reviews"
```

`comments.json` 每一項是 `{"path": "<path>", "new_position": <N>, "body": "<理由 + suggestion 區塊>"}`。

- `new_position` 填新版行號 N（不是 diff 裡的位置）。
- `event` 用 `COMMENT`。審自己開的 PR 時 Gitea 只接受這個。

### 6. 驗證並回報

`GET $API/pulls/<n>/reviews/<review id>/comments`，確認：

- 留言數等於送出的則數（多出來的就是步驟 2 漏掉的草稿，告訴使用者）。
- 每則的 `position` 等於送出的 N。

完成條件：數量與行號都對上。回報 review 的網址
（`https://<GIT_HOST>/<ORG>/<SPEC_REPO>/pulls/<n>/files`）與則數。
