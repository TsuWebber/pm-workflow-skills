---
description: 依前後端 repo 產生以 User Story 為維度的 DDD/BDD Gherkin spec
argument-hint: <前端 repo 路徑> <後端 repo 路徑> <要生成 spec 的功能>
allowed-tools: Read, Grep, Glob, Bash, Write
---

# /output-story

你要為指定功能產生一份 **以 User Story 為維度** 的 spec，spec 中每一項驗收條件都必須是符合下方 **DDD Gherkin 撰寫規範** 的測資。

## 輸入

使用者透過參數提供：

- **前端 repo 路徑**：`$1`
- **後端 repo 路徑**：`$2`
- **要生成 spec 的功能**：`$3`（可能是多個詞，取 `$3` 之後的全部內容為功能描述）

完整參數：`$ARGUMENTS`

若任一必要資訊缺漏（前端路徑 / 後端路徑 / 功能），先向使用者詢問後再繼續，不要自行臆測路徑。

## 工作流程

1. **理解功能**
   - 讀取前端 repo（`$1`）與後端 repo（`$2`）中與功能（`$3`）相關的程式碼。
   - 前端優先看：route、page/view、component、API client、i18n 文案。
   - 後端優先看：route/controller、request validation、service、domain model、event/listener、DB schema/migration。
   - 目標是還原 **Business Behavior**，不是抄 UI 流程或 API 規格。

2. **範圍界定：排除不需要審視的程式碼**
   - 在分析程式碼前，先依下方「範圍界定規則」過濾，跳過不需要產 Spec 的程式碼。
   - 只對「有外部進入點」的程式碼產生 Scenario。

3. **萃取 Ubiquitous Language**
   - 從程式碼與文案整理出該功能的 Domain Terms（業務物件、業務角色、業務動作）。
   - Actor 一律使用 Business Role（商品管理員、物流人員、客戶…），禁止用 RD/QA/前端/後端 等技術角色。

4. **拆分 User Story**
   - 以業務價值為維度，將功能拆成多個 User Story。
   - 每個 User Story 用 `As a / I want / So that` 描述。

5. **為每個 User Story 產生 Gherkin**
   - 每個 User Story 對應一個 Feature 或一組 Scenario。
   - 必須同時涵蓋 **Happy Path 與 Unhappy Path**（必填、權限、業務規則衝突、邊界）。
   - 同一規則多變體用 `Scenario Outline` + `Examples`，不要複製近乎相同的 Scenario。
   - 共用前提抽到 `Background`。
   - 依下方「判斷矩陣」決定每個邏輯分支該不該寫 Scenario。

6. **輸出 spec**
   - 在**後端 repo（`$2`）**下建立 `specs/` 目錄（若無），輸出檔名 `specs/<功能-kebab-case>.feature.md`。
   - 若使用者另有指定輸出位置則以使用者為準。
   - 產出後回報檔案路徑與涵蓋的 User Story 清單。

7. **自我檢驗**（產出前逐條確認）
   - 這是在描述 Business Rule 嗎？（不是 UI Flow / API Spec）
   - UI 全部重寫後這個 Scenario 還成立嗎？
   - PO、RD、QA 都能據此理解並實作出相同功能嗎？
   - 三個答案都是 Yes 才算合格。

## 輸出格式範本

````markdown
# Spec: <功能名稱>

> 來源 repo：前端 `$1`／後端 `$2`
> Ubiquitous Language：<列出本功能用到的 Domain Terms>

## User Story 1: <標題>

**As a** <業務角色>
**I want** <想達成的事>
**So that** <業務價值>

```gherkin
Feature: <功能>
  As a <業務角色>
  I want <想達成的事>
  So that <業務價值>

  Background:
    Given <共用業務前提>

  # Happy Path
  Scenario: <成功情境>
    Given ...
    When ...
    Then ...

  # Unhappy Path
  Scenario: <失敗/邊界情境>
    Given ...
    When ...
    Then ...
```

## User Story 2: <標題>
...
````

---

# DDD Gherkin 撰寫規範（Rules）

## 核心理念

Gherkin 的目的是描述 **Business Behavior（業務行為）**，而不是 UI 操作流程或 API 規格。它應該讓 PO、RD、QA 都能閱讀並理解相同的業務規則。

## 1. 語言規範：使用 Ubiquitous Language

所有描述必須使用業務領域語言，禁止出現以下類別的詞彙：

| 禁止類別   | 常見詞彙範例                                               |
| ---------- | ---------------------------------------------------------- |
| UI 元件    | Button, Dropdown, Modal, Toast, Table, Checkbox, Tab ...   |
| UI 操作    | 點擊, 按 Enter, Scroll, 左鍵雙擊, Auto Complete ...        |
| API / HTTP | API 200/400/500, Request Body, Response JSON, Endpoint ... |
| 技術實作   | DB Table, Controller, DTO, Service, Repository ...         |

應使用業務角色的動作與業務物件來描述：

```gherkin
# Bad
When 點擊「建立」按鈕
And 選擇 Dropdown
Then Toast 顯示成功

# Good
When 商品管理員建立商品
Then 商品成功建立
```

```gherkin
# Bad
Then API 回傳 200

# Good
Then 系統成功完成建立
```

## 2. 結構規範

### 2.1 Feature 描述格式
每個 Feature 開頭應包含 `As a / I want / So that`，說明業務價值。

### 2.2 Background：抽取共用前提
多個 Scenario 共用相同 Given 前提時，用 `Background` 避免重複。

### 2.3 一個 Scenario = 一個 Business Rule
每個 Scenario 只驗證一條業務規則，不要在同一 Scenario 串接多個獨立行為。

### 2.4 Scenario Outline：同一規則的多種變體
同一 Business Rule 有多種 input/output 時，用 `Scenario Outline` + `Examples`。

```gherkin
Scenario Outline: 商品建立欄位驗證
  Given 商品管理員正在建立商品
  When 輸入 <欄位> 為 <值>
  And 嘗試建立商品
  Then 系統提示 <結果>

  Examples:
    | 欄位 | 值   | 結果         |
    | 名稱 | 空白 | 名稱為必填   |
    | 價格 | -1   | 價格須為正數 |
    | SKU  | 重複 | SKU 不可重複 |
```

### 2.5 Given / When / Then 的職責

| 關鍵字    | 描述                   | 注意                         |
| --------- | ---------------------- | ---------------------------- |
| **Given** | 業務前提、系統初始狀態 | 描述業務狀態，不描述 UI 狀態 |
| **When**  | 業務動作、Actor 行為   | 描述意圖，不描述操作細節     |
| **Then**  | 業務結果、預期系統行為 | 描述業務結果，不描述 UI 回饋 |

## 3. Actor 規範

Actor 應為 Business Role：商品管理員、物流人員、客戶、行銷人員、系統（自動觸發時）。禁止：RD、QA、前端、後端、DevOps。

## 4. 涵蓋範圍：Happy Path + Unhappy Path

必須涵蓋常見失敗與邊界：必填欄位、權限不足、業務規則衝突（如庫存不足）。

但**不需要覆蓋**以下類型的 unhappy path：
- 純防禦性 null/empty check（除非是使用者可觸發的場景）
- 純技術層 catch → log（不影響業務流程的錯誤處理）
- 內部資料組裝的條件分支
- 無外部進入點的 dead code

## 5. 穩定性檢驗

好的 Scenario 具備穩定性——UI 可以改，但 Scenario 不應該改。無論前端從 Dropdown 改成 Tree Select、Search Dialog、甚至 API 自動搜尋，只要 Business Rule 沒變，Scenario 就不需修改。

## 6. 不屬於 Gherkin 的內容

| 內容                     | 應放置的位置                         |
| ------------------------ | ------------------------------------ |
| Migration / DB Script    | Migration Test, Deployment Checklist |
| RD 操作（如執行 Script） | Integration Test                     |
| 技術實作細節             | Architecture Decision Record (ADR)   |
| UI 操作流程              | UI Test (Cypress / Playwright)       |

---

# 範圍界定規則：什麼程式碼需要審視

在判斷「該不該寫 Scenario」之前，先判斷「這段程式碼該不該被審視」。

## 納入範圍

| 類型         | 條件                                     | 說明                        |
| ------------ | ---------------------------------------- | --------------------------- |
| Controller   | 有 route 定義                            | API 端點 = 外部進入點       |
| Service      | 被 Controller/Job/Listener/Command 呼叫  | 有活躍的呼叫鏈              |
| Job          | 被 dispatch 或出現在 queue 中            | 有觸發來源                  |
| Listener     | 註冊在 EventServiceProvider              | 有 event 觸發               |
| Command      | **出現在排程（Kernel schedule）中**      | 排程 = 系統自動觸發的進入點 |
| Repository   | 被 Service/Controller 呼叫               | 有活躍的呼叫鏈              |
| Model method | 被業務邏輯呼叫的 scope/accessor/狀態方法 | 影響業務行為                |

## 排除範圍

| 類型                     | 條件                                  | 說明                         |
| ------------------------ | ------------------------------------- | ---------------------------- |
| Command（非排程）        | 不在 Kernel schedule 中，僅供手動執行 | 運維工具，不是系統行為承諾   |
| Dead code                | 沒有任何外部進入點呼叫                | 無人觸發的程式碼不需要 Spec  |
| DataMigration Command    | 一次性資料修補                        | 執行完即廢棄                 |
| Base/Abstract class      | 無直接業務邏輯                        | 框架結構，非業務行為         |
| Helper/Utility（純函式） | 字串格式化、數學計算等                | 單元測試的範疇，非 Spec 範疇 |
| Test class               | 測試程式碼本身                        | —                            |

## 判斷流程

```
程式碼 class
  │
  ├─ 有外部進入點嗎？（route / schedule / event / dispatch / 被呼叫）
  │   ├─ 是 → 納入審視 → 接著用「判斷矩陣」決定該不該寫 Scenario
  │   └─ 否 → 排除，不審視
  │
  └─ 是 Command 嗎？
      ├─ 在 Kernel schedule 中 → 納入（它是系統自動觸發的行為）
      └─ 不在 schedule 中 → 排除（它是手動運維工具）
```

---

# Scenario 判斷矩陣：什麼邏輯該寫、什麼不該寫

| 程式碼邏輯類型             | 該寫 Scenario？ | 判斷標準                           | 範例                                           |
| -------------------------- | :-------------: | ---------------------------------- | ---------------------------------------------- |
| 核心業務流程               |    **必須**     | 使用者或營運人員可觀察到的行為     | 訂單取消後庫存回補、優惠券折扣計算             |
| 業務規則的 unhappy path    |    **必須**     | 使用者會收到錯誤訊息或行為改變     | 庫存不足拒絕結帳、優惠券過期不可用             |
| 狀態轉換                   |    **必須**     | 實體的狀態變化是業務承諾的一部分   | 訂單 PROCESSING → COMPLETED、發票 VOID         |
| 冪等機制（Job/Listener）   |    **應該**     | 重複觸發時「不重複執行」是業務承諾 | 「已處理過的訂單不重複扣減統計」               |
| 權限/資格檢查              |    **應該**     | 「誰能做什麼」是業務規則           | 非官網訂單不發放點數、B2B 強制登入             |
| 跨系統同步觸發條件         |    **應該**     | 「什麼時候觸發同步」是行為承諾     | 訂單完成後同步 WP、付款成功後建出貨單          |
| 平台/通路分流              |   **視情況**    | 分流結果影響使用者體驗時才寫       | 蝦皮訂單 vs 官網訂單的配送方式差異             |
| Early return（null/empty） |  **通常不寫**   | 除非 null 狀態是使用者可觸發的場景 | ~~`Order::find() 為 null → skip`~~             |
| 內部資料組裝               |    **不寫**     | 欄位拼接、cache key 格式等實作細節 | ~~備註欄位的 6 個 if 條件組裝~~                |
| 例外處理（catch → log）    |    **不寫**     | 純技術層的錯誤記錄                 | ~~`Exception catch 後 Logger.error`~~          |
| 防禦性型別檢查             |    **不寫**     | 程式語言層級的安全防護             | ~~`if (!is_array($x)) return`~~                |
| 非排程 Command             |   **不審視**    | 手動運維工具，不是系統行為承諾     | ~~`exec:issue_invoice`、`ListRoles`~~          |
| Dead code（無進入點）      |   **不審視**    | 沒有外部呼叫鏈的程式碼             | ~~未被任何 route/event/schedule 觸發的 class~~ |
| DataMigration Command      |   **不審視**    | 一次性資料修補，執行完即廢棄       | ~~`@deprecated 2506` 的 Command~~              |

## 灰色地帶的判斷流程

遇到不確定該不該寫 Scenario 時，依序問自己：

```
1. 這個行為是使用者/營運人員可以觀察到的嗎？
   → 是 → 寫
   → 否 → 繼續

2. 這個行為失敗時，會影響資料正確性嗎？
   → 是 → 寫（如冪等、跨系統同步）
   → 否 → 繼續

3. 這個行為是業務規則的一部分嗎？（如資格判斷、狀態限制）
   → 是 → 寫
   → 否 → 繼續

4. 換一種實作方式，這個行為還需要存在嗎？
   → 是 → 寫（它是業務需求）
   → 否 → 不寫（它是實作選擇）
```

---

# Scenario 撰寫風格

## 用業務語言，不用程式碼語言

```gherkin
# Good
Given 消費者的紅利點數餘額為 500 點
When 該訂單被取消
Then 消費者的點數餘額恢復為 700 點

# Bad
Given OrderCancelPointsReverser 收到 OrderCancelled event
When creditReverse 執行完成
Then cosign_member 的 point_balance 更新為 700
```

## 用結果描述，不用過程描述

```gherkin
# Good
Then 系統不重複發放紅利點數

# Bad
Then 系統檢查 metadata flag has_given_reward_point 為 true 後 early return
```

## 一個 Scenario 測一個行為

```gherkin
# Good
Scenario: 未使用優惠券的訂單取消後不影響任何優惠券
  Given 一張訂單未使用任何優惠券
  When 該訂單被取消
  Then 不更新任何優惠券的使用摘要

# Bad
Scenario: 訂單取消後的完整流程
  Given 一張訂單使用了優惠券並折抵點數
  When 該訂單被取消
  Then 優惠券使用次數減 1
  And 點數餘額恢復
  And 庫存回補
  And 會員統計更新
  And 風控記錄撤銷
```

## 冪等 Scenario 的寫法

```gherkin
# Good — 表達業務承諾
Scenario: 已處理過的訂單不重複扣減會員統計
  Given 一張訂單的會員統計已更新完成
  When 系統因重試機制再次處理同一張訂單
  Then 不重複扣減會員消費統計

# Bad — 暴露實作細節
Scenario: Redis lock 取得失敗時跳過處理
  Given 另一個程序正在處理同一筆訂單
  When 系統嘗試取得 Redis lock
  Then 系統跳過本次處理
```

---

# 覆蓋率期望

| 層級                         | 目標覆蓋率 | 說明                                 |
| ---------------------------- | :--------: | ------------------------------------ |
| 核心業務流程                 |  **95%+**  | 所有使用者可見行為都要有 Scenario    |
| 狀態轉換                     |  **90%+**  | 所有合法/非法轉換都要有 Scenario     |
| 冪等/並發保護                |  **80%+**  | Job/Listener 的冪等承諾要有 Scenario |
| 權限/資格判斷                |  **80%+**  | 「誰能做什麼」的業務規則             |
| 整體邏輯分支（含排除項）     | **60-70%** | 扣掉不該寫的 edge case 後的自然結果  |
| 整體邏輯分支（僅審視範圍內） | **75-85%** | 排除 dead code / 非排程 Command 後   |

**60-70% 的整體邏輯分支覆蓋率是健康的。** 超過 85% 可能代表寫了太多實作細節的 Scenario，增加維護成本。
