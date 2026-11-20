# PR Apply Suggestions（套用 PR 上的建議修改）

## 定位

needle 在網頁上一次只能套用一則，每則各一個 commit。這個 skill 在本地一次套用多則，
套用規則跟 needle 相同：**用建議區塊的內容取代留言掛的那一行**。

這個 skill 只改本地檔案。commit 與 push 交給 [`pm-ship`](ship.md)。

---

## 步驟

### 1. 取得 PR 與憑證

- PR 編號由使用者提供；沒給就列出開著的 PR 請使用者選。
- 憑證沿用 [`pm-ship（開 PR 步驟）`](pr.md) 第 5 步的路徑 2 或 3。
  以下 `$AUTH` 是 curl 的認證參數，`$API` 是
  `https://<GIT_HOST>/api/v1/repos/<ORG>/<SPEC_REPO>`。**絕不印出密碼或 token**。
- `GET $API/pulls/<n>`，記下 `head.ref`。

### 2. 收集建議

1. `GET $API/pulls/<n>/reviews` 取得所有 review。
2. 對每個 review：`GET $API/pulls/<n>/reviews/<id>/comments`。
3. 留下 `body` 含 ```suggestion 區塊的留言，依留言 `id` 去重。
4. 先把 `body` 的 `\r\n` 換成 `\n` —— 網頁上寫的留言是 CRLF，不換會把 `\r` 寫進檔案。
5. 分類：
   - **可套用**：`resolver` 為 null，且 `position` > 0。
   - **已解決**：`resolver` 不為 null，略過。
   - **掛在被刪除的行**：`position` 為 0。新檔案裡沒有那一行，列出來說明，不套用。

每則可套用的建議記下：`id`、留言者、`path`、目標行 N（= `position`）、取代內容（區塊裡的所有行），
以及**預期原文**，依序取第一個有的來源：

1. 內文裡的 `<!-- original: … -->` 標記（`pm-ship suggest` 留的建議都有）。
2. `diff_hunk` 去掉結尾的換行後取最後一行，再去掉開頭的 `+` 或空白。掛在 diff 區段外的留言，
   Gitea 會補一段以目標行收尾、結尾多一個換行的區段，所以要先去掉換行。

完成條件：每則留言都歸進三類之一，每則可套用的建議都有預期原文。

### 3. 給使用者挑選

```
PR #<n>，可套用 K 則（已解決 A 則、掛在被刪除的行 B 則）：
1. [<留言者>] <path>:<N>
   原文：<預期原文>
   建議：<取代內容>
```

作者決定套哪幾則。同一行有兩則以上建議時，請作者選一則。

### 4. 切到 PR 分支

- 確認 working tree 乾淨（`git status --porcelain` 為空）；有未提交的改動就停下來問。
- `git fetch origin && git switch <head.ref> && git pull --ff-only`。

### 5. 核對並套用

每個檔案內**由行號大到小**套用，前面套用時增減的行數就不會影響後面的行號。

每則建議：

1. **核對**：檔案第 N 行要等於預期原文。
2. **對不上時**（留言之後分支又被改過）：在檔案裡找預期原文。剛好出現一次就改用那一行；
   出現零次或多次就略過這則，記下原因。
3. **取代**：把那一行換成取代內容的所有行。

完成條件：每則建議都是「已套用」或「略過 + 原因」其中之一。

### 6. 收尾

1. 秀 `git diff` 給使用者看。
2. 改到的是 `drafts/` 裡的 `spec.md` 時，在同資料夾的 `changelog.md` 補一筆：
   `- YYYY-MM-DD 套用 PR #<n> 的 K 則審閱建議（<留言者>）`。日期用使用者提供的當天日期。
3. 提示使用者跑 `pm-ship` 提交並推送到同一個 PR。
4. 回報略過的建議與原因。
5. 提醒使用者推送後到 PR 網頁把已套用的對話標成已解決。
