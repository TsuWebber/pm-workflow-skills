---
name: setup
description: 幫 PM 把 spec repo 需要的工具一次裝好並完成授權（git / Gitea 憑證 / tea / rclone / claude / code），並診斷內網、身分、授權是否到位。全程由助手代跑，PM 不必碰終端機。使用時機：新 PM 第一天上手、換新電腦、或某個指令突然說「找不到 xxx」「沒有權限」。觸發語如「幫我把環境裝好」「環境檢查」「新電腦要裝什麼」「rclone 找不到」「push 一直要密碼」。可重複跑，已裝好的不會重裝。
---

# Setup（環境健檢 + 一次裝好）

## 定位

[ONBOARDING.md](../../../ONBOARDING.md) 是給 PM 讀的入門文，主推「Claude Desktop、不碰終端機」那條路。
**這個 skill 是它的另一半**：PM 只要說一句「幫我把環境裝好」，**由你（助手）代跑所有安裝與授權**——
PM 依然不用碰終端機、不用背指令。

**核心心法：先診斷，再動手。** 不要一上來就 `brew install` 一輪——多數情況多數東西已經在了。
先跑 [doctor.sh](./doctor.sh) 看缺什麼，只補缺的。

**這個 skill 不做的事**：
- 不替 PM 完成**需要本人點瀏覽器**的授權（Google / Atlassian / Notion）——你只能把他帶到那一步，按鈕他自己按。
- 不碰 MCP 連接器設定（那在 Claude Desktop / VSCode 裡做，見 ONBOARDING〈連接外部服務〉）。
- 不 clone 倉庫（那是 ONBOARDING Step 3 的事）。

---

## When To Use

適用：
- 新 PM 第一天、或換了新電腦
- 某個指令突然壞掉：「找不到 rclone」「push 一直要我輸密碼」「開 PR 失敗」
- 想確認「我的環境到底哪裡沒設好」

不適用：
- 只是要 clone 倉庫 → 照 [ONBOARDING.md](../../../ONBOARDING.md) Step 3
- 要接 JIRA / Notion → 那是 MCP，打 `/mcp` 授權，見 ONBOARDING〈連接外部服務〉

---

## 各工具是幹嘛的（要能跟 PM 用白話解釋）

| 工具 | 白話 | 沒有它會怎樣 | 必要性 |
|---|---|---|---|
| **git** | 規格的存檔 / 版本系統 | 什麼都做不了 | **必要** |
| **Gitea 憑證** | 免密碼跟公司倉庫溝通 | 每次 push / 開 PR 都要打帳密 | **必要** |
| **rclone** | 把圖片傳上 Google Drive | `/images-to-drive` 不能用，Notion 的圖搬不進來 | **必要**（規格幾乎都有圖）|
| **claude** | 助手本人 | —— | 已在用就代表有了 |
| **tea** | Gitea 的命令列工具 | `/pr` 會改走 API 備援，**仍可開 PR** | 選配 |
| **code** | 從終端機開 VSCode | 只是方便，不影響寫規格 | 選配 |

> 跟 PM 溝通時**不要念工具名**。說「你的存檔系統」「傳圖片的工具」，不是「rclone 的 remote 沒授權」。

---

## Step 1：先診斷

```bash
bash .claude/skills/setup/doctor.sh
```

輸出每行 `狀態<TAB>項目<TAB>說明`：`OK`（好了）/ `TODO`（要處理）/ `WARN`（能用但有隱憂）。

**先看「內網連線」那一行。** 如果它是 `TODO`，**停下來先解決 VPN**——
內網不通的話，Gitea 憑證、clone、push 全都會失敗，你在那之前裝再多工具都是白工。
這一項助手修不了，請 PM **找 MIS**。

全部 `OK` → 跟 PM 說「環境沒問題」，結束，不要沒事找事重裝。

---

## Step 2：安裝缺的（代 PM 跑）

**先報告再動手**：列出「我要裝這幾個、大概幾分鐘」，PM 說好再跑。

| 工具 | mac | Windows |
|---|---|---|
| git | `brew install git`（多半內建，通常不用裝） | `winget install Git.Git` |
| rclone | `brew install rclone` | `winget install Rclone.Rclone` |
| tea | `brew install tea` | 到 [gitea.com/gitea/tea/releases](https://gitea.com/gitea/tea/releases) 下載執行檔放進 PATH |
| code | 裝 [VSCode](https://code.visualstudio.com) 後，在 VSCode 內 `Cmd/Ctrl+Shift+P` → `Shell Command: Install 'code' command in PATH` | 安裝時勾「Add to PATH」 |
| claude | `curl -fsSL https://claude.ai/install.sh \| bash` | PowerShell：`irm https://claude.ai/install.ps1 \| iex` |

- **mac 沒有 brew** → 先裝 Homebrew（<https://brew.sh>），其餘都靠它。
- **Claude Code 跑在 WSL** → 工具要裝在 **WSL 裡**，不是 Windows 端。裝錯邊會出現「明明裝了卻找不到」。
- 安裝要花幾分鐘，用背景跑、跟 PM 說一聲，不要讓他以為當掉了。

---

## Step 3：完成授權（這才是真正會卡住的地方）

裝好 ≠ 能用。逐項帶完，**每一項做完都用 doctor.sh 複驗**。

### 3-1 git 身分

```bash
git config --global user.name  "<PM 的名字>"
git config --global user.email "<PM 的公司 email>"
```
**名字與 email 一定要問 PM**，不要自己編——這會印在每一筆 commit 上洗不掉。

### 3-2 Gitea 憑證（解決「push 一直要密碼」）

第一次 `git push` / clone 時輸入 Gitea 帳密，macOS 會自動存進 Keychain，之後免打。
- 沒有 Gitea 帳號 → **找任一位 RD Leader 開**。
- 一直失敗 → 九成是 **VPN 沒連**，回頭看 Step 1。

### 3-3 rclone → Google Drive

```bash
rclone config create gdrive drive scope=drive
```
**會自動跳出瀏覽器。先告訴 PM：「等一下會跳出 Google 登入頁，請用公司帳號登入並按『允許』。」**
他按完就結束，token 存進本機 `rclone.conf`（權限 600），之後不必再授權。

- 瀏覽器沒跳出來（SSH / 無頭環境）→ 改跑 `rclone authorize drive`，把它印出的 token 貼進
  `rclone config create gdrive drive scope=drive token='<貼上>'`。
- ⚠️ **rclone 的授權輸出含 refresh token 明碼**。若你用背景執行、輸出被寫進暫存檔，**跑完把那個檔刪掉**。
- ⚠️ 預設用 rclone 共用的 client_id，**2026 年內會停用**。詳見 `images-to-drive` skill 的 Step 0。

### 3-4 tea（選配）

```bash
tea login add --name spec repo --url https://<GIT_HOST> --token <TOKEN>
```
TOKEN 要 PM 自己到 Gitea 產：**右上角頭像 → Settings → Applications → Generate New Token**（勾 `repo` 權限）。
- **不要幫 PM 貼 token 到任何會留檔的地方**，也不要 echo 出來。
- 嫌麻煩就跳過——`/pr` 沒有 tea 也能開 PR（走 git credential + API）。

### 3-5 claude / code

- `claude`：你正在跑，就代表有了。PATH 上沒有多半是走 Claude Desktop / VSCode 擴充，**屬正常，不用修**。
- `code`：純方便，PM 不想裝就跳過。

---

## Step 4：複驗 + 回報

再跑一次 `doctor.sh`，然後用**白話**回報，不要貼原始輸出。

```
✅ 環境好了

已經幫你裝好 / 設定好：
- 存檔系統（git）—— 你的名字已設定為 <名字>
- 跟公司倉庫溝通的憑證 —— 之後 push 不用再打密碼
- 圖片上傳工具 —— Notion 的圖可以自動搬上 Google Drive 了

還缺（需要你本人動手，我沒辦法代按）：
- <例：VPN 沒連上 → 請找 MIS>
- <例：Gitea 帳號還沒開 → 請找任一位 RD Leader>

可以開始了：跟我說「我想做 <某功能>」就會帶你寫第一份規格。
```

**沒裝成的東西要照實說**，不要含糊帶過——PM 會在下一個指令壞掉時才發現，那更糟。

---

## Writing Rules

- 一律繁體中文；指令、工具名保留英文。
- **先診斷、只補缺的**，不要無腦重裝一輪。
- **會留下痕跡的設定一定先問 PM**（git 的 name / email 會永久印在 commit 上）。
- **token / 密碼絕不 echo、絕不寫進 repo、絕不留在暫存檔**。rclone 授權的背景輸出跑完就刪。
- 需要本人點瀏覽器的授權（Google / Gitea / Atlassian）→ **明講「這步只有你能按」**，並說清楚會跳出什麼、要點哪裡。
- 回報用白話講「你現在能做什麼」，不要念工具名和版本號。
