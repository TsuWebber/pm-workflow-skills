# ADF 描述範本

Jira description 統一使用 `contentFormat: adf`，從下方選對應範本填入實際內容。

---

## Bug 票

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "panel",
      "attrs": { "panelType": "warning" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "問題描述：", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "（現象說明）" }
          ]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "重現步驟" }]
    },
    {
      "type": "orderedList",
      "content": [
        { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "步驟 1" }] }] },
        { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "步驟 2" }] }] }
      ]
    },
    {
      "type": "panel",
      "attrs": { "panelType": "success" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "預期行為：", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "（應該要發生什麼）" }
          ]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "實際行為" }]
    },
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "（實際發生什麼）" }]
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "環境" }]
    },
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "{environment}" }]
    }
  ]
}
```

---

## Sprint Bug Subtask

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "panel",
      "attrs": { "panelType": "warning" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "Bug 描述：", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "（問題現象說明）" }
          ]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "重現步驟" }]
    },
    {
      "type": "orderedList",
      "content": [
        { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "步驟 1" }] }] },
        { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "步驟 2" }] }] }
      ]
    },
    {
      "type": "panel",
      "attrs": { "panelType": "success" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "預期行為：", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "（應該要發生什麼）" }
          ]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "實際行為" }]
    },
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "（實際發生什麼）" }]
    }
  ]
}
```

---

## 工作票（Task）

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "panel",
      "attrs": { "panelType": "info" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "任務說明：", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "（任務描述，保留原文）" }
          ]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "執行細節" }]
    },
    {
      "type": "bulletList",
      "content": [
        { "type": "listItem", "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "（細項說明，若有）" }] }] }
      ]
    }
  ]
}
```

---

## 優化票（Story）— 一般優化

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "panel",
      "attrs": { "panelType": "info" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "背景：", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "（說明現況與問題根源）" }
          ]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "問題描述 / Problem Statement" }]
    },
    { "type": "bulletList", "content": [] },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "優化目標 / Goals" }]
    },
    { "type": "bulletList", "content": [] },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "提案方向 / Proposed Solutions" }]
    },
    { "type": "orderedList", "content": [] },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "影響範圍 / Scope" }]
    },
    { "type": "paragraph", "content": [{ "type": "text", "text": "..." }] },
    {
      "type": "heading",
      "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "驗收條件 / Acceptance Criteria" }]
    },
    { "type": "bulletList", "content": [] }
  ]
}
```

**撰寫原則：**
- 提案方向至少 2 個選項
- AC 要可量測，避免「讓使用者滿意」
- 影響範圍需提醒是否有其他頁面使用相同 pattern

---

## 優化票（Story）— 配套溝通票

標題格式：`【配套溝通】【模組】描述`

色塊對應：
- 藍色（背景）→ `panelType: info`
- 紫色（先前已處理）→ `panelType: note`
- 綠色（還需要達到）→ `panelType: success`

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [
        { "type": "text", "text": "延續：" },
        { "type": "text", "text": "[前一張票連結]", "marks": [{ "type": "link", "attrs": { "href": "https://your-team.atlassian.net/browse/PROJ-XXXXX" } }] }
      ]
    },
    {
      "type": "panel",
      "attrs": { "panelType": "info" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "背景：", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "（說明業務背景、問題根源與跨部門決議）" }
          ]
        }
      ]
    },
    {
      "type": "panel",
      "attrs": { "panelType": "note" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "先前已處理 ", "marks": [{ "type": "strong" }] },
            { "type": "text", "text": "[相關票連結]", "marks": [{ "type": "link", "attrs": { "href": "https://your-team.atlassian.net/browse/PROJ-XXXXX" } }] }
          ]
        }
      ]
    },
    {
      "type": "orderedList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                { "type": "text", "text": "【模組名稱】需求描述" },
                { "type": "hardBreak" },
                { "type": "text", "text": "注意：驗收重點", "marks": [{ "type": "strong" }] }
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "panel",
      "attrs": { "panelType": "success" },
      "content": [
        {
          "type": "paragraph",
          "content": [
            { "type": "text", "text": "還需要達到：", "marks": [{ "type": "strong" }] }
          ]
        },
        {
          "type": "orderedList",
          "content": [
            {
              "type": "listItem",
              "content": [
                { "type": "paragraph", "content": [{ "type": "text", "text": "待辦需求 1" }] },
                {
                  "type": "orderedList",
                  "content": [
                    {
                      "type": "listItem",
                      "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "現況：描述目前狀況", "marks": [{ "type": "strong" }] }] }]
                    },
                    {
                      "type": "listItem",
                      "content": [{ "type": "paragraph", "content": [{ "type": "text", "text": "需求：描述期望行為", "marks": [{ "type": "strong" }] }] }]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```
