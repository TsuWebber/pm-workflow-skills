# pm-config（範本）

複製到 `~/.claude/pm-config.md`，把值換成自己的環境。每個 pm-* skill 執行前都會讀這份檔案，skill 本體不需要改。

這份檔案只放在自己電腦（或私人備份），不要推到公開 repo。

## 規格庫

- 路徑：`<SPEC_REPO_PATH>`（例：`~/work/spec-repo`）
- Git 平台：`<GIT_HOST>`（例：`git.example.com`，預設流程以 Gitea 為準）
- 組織 / repo：`<ORG>` / `<SPEC_REPO>`
- 預設分支：`main`

## Jira

- 網域：`your-team.atlassian.net`
- 專案代碼：`PROJ`
- Team 欄位 ID：`<CUSTOM_FIELD_ID>`；可選的 team：`<TEAM_NAME>`、…
- Sprint 欄位 ID：`<CUSTOM_FIELD_ID>`
- Environment 欄位 ID：`<CUSTOM_FIELD_ID>`
- Epic 清單：寫在下方，或改 `pm-ticket/reference/ticket/references/epic-mapping.md`

## Notion

- 任務資料庫：`<NOTION_DB_ID>`（`pm-report daily`、`weekly` 用）
- 週會筆記資料庫：`<NOTION_DB_ID>`
- 規格展示頁的上層頁面：`<PAGE_ID>`（`pm-ship notion` 用）

## 群組與其他來源

- 群組對話匯出資料夾：`<DINGTALK_EXPORT_DIR>`（`pm-report digest`、`pm-launch retro` 用）
- Google Drive 圖片資料夾：`<FOLDER_ID>`（`pm-intake notion` 用）
- 前後端 repo 路徑（`pm-spec reverse`、`pm-launch sync-code` 用）：`<BACKEND_REPO_PATH>`、`<FRONTEND_REPO_PATH>`

## 公司專有名詞

| 名詞 | 意思 |
|---|---|
| OMS | 訂單管理系統 |
| 經銷商平台 | 給經銷商下單的網站 |
| 2B / 2C | 經銷通路 / 消費者通路 |

## 部門與職責

| 部門 | 負責 |
|---|---|
| 產品 | 商品規格、SKU 規劃 |
| 營運 | 商品主檔、設定維護 |
| 財務 | 會計科目、成本與收入認列、對帳 |
| 物流 | 進貨、出貨、退貨驗收 |
| 客服 / 業務 | 對消費者 / 經銷商的第一線溝通 |
