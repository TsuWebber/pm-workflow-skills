---
name: human-readable-writing
description: Formatting, wording, and section-structure rules for all human-readable text in Chinese, English, or mixed Chinese-English. Always apply this skill when writing or revising READMEs, PR descriptions, commit messages, code comments, reports, documentation, skill / agent instruction files, announcements, emails, Slack messages, or any prose a human will read — even if the user does not explicitly mention formatting. Also apply when a reader says a word is hard to understand (「這個詞看不懂」「很難懂」), when renaming a term across files, when importing a document from another project, or when aligning a new file with an existing house style. Do NOT apply to code syntax itself.
---

# Human-Readable Writing Format

Rules for producing readable text in Chinese (Traditional), English, and mixed Chinese-English content.

## Scope

**Applies to**: README, PR descriptions, commit messages, code comments, reports, docs, announcements, chat messages — any text written for humans.

**Does NOT apply to**: code syntax (function arguments, statement terminators, object keys, YAML/JSON), URLs (`https://`), time formats (`12:30`), file paths, version numbers, or any machine-parsed string.

**Also does NOT apply to structural names** — see Rule 6. A table column header, a fixed section name, a schema key, or a cross-referenced shorthand is an identifier that other files must match, not prose.

## Rule 1: Space after half-width punctuation (highest priority)

Always add exactly one space after these half-width marks in prose:

- Comma `,` → `A, B, C`
- Semicolon `;` → `first step; second step`
- Colon `:` → `Note: this is important`

Examples:

- ✅ `支援平台: Shopee, momo, PChome`
- ❌ `支援平台:Shopee,momo,PChome` (missing spaces)
- ✅ `deploy 流程分兩步: build; release`

Exceptions (never add a space):

- Inside code, inline code spans, and code blocks: `foo(a,b)` stays as-is per language convention
- URLs: `https://example.com`
- Time and ratios: `12:30`, `16:9`
- Emoticons or literal strings quoted from elsewhere

## Rule 2: Spacing between CJK and half-width characters

Add one space between Chinese characters and adjacent English words, numbers, or inline code:

- ✅ `我們使用 Laravel 開發, 預計 3 天完成`
- ❌ `我們使用Laravel開發,預計3天完成`

Do not add a space between CJK characters and full-width punctuation, or between a number and its unit percent sign (`80%` is fine).

## Rule 3: Punctuation choice in Chinese text

- Full sentences in Chinese use full-width `。「」、?!` as usual
- Half-width `,` `;` `:` may be used in mixed technical text (this user's preferred style) — when used, Rule 1 applies
- Never mix full-width and half-width versions of the same mark inconsistently within one document; pick one style per document

## Rule 4: General readability

- Prefer short paragraphs (2–4 sentences) over walls of text
- Left-align body text; never center long paragraphs
- Use headings and bold to create visual hierarchy for key info (dates, deadlines, breaking changes)
- Put warnings or irreversible consequences (e.g. "逾期未使用將自動失效") in a highlighted standalone line, not buried mid-paragraph
- For old-vs-new comparisons (policy changes, migrations), prefer a small table over prose
- In English text, use sentence case for headings; one space after sentence-ending periods

## Rule 5: Plain words beat imported jargon

Before introducing an English or borrowed term, check whether the document set already has a plain word for the same thing. `grep` the sibling files first, then reuse what you find. Do not coin a synonym.

- ✅ 「開始掃之前先確認」/「放行判斷」— 讀者不用先懂任何隱喻
- ❌ 「Step 0：掃案例前的 gate」— `gate` 是隱喻, 要先想通「門」才讀得懂這一段

**One concept, one word.** Three near-synonyms for the same idea (`gate` / 關卡 / 放行) cost more than the one they replace, because the reader has to keep checking whether they mean different things.

**Name a section by what the reader does in it**, not by the mechanism:

| ❌ 機制當段名 | ✅ 動作當段名 |
|---|---|
| `## Input Requirements（輸入）` | `## Step 0：開始掃之前先確認` |
| `## Output Requirements（輸出）` | `## 落地到 drafts（每次掃完都要做）` |
| `## gate 分級（擋下 vs 提醒）` | `## 分級：哪些擋下、哪些只提醒` |

When a reader says a word is hard to understand, that is the finding — do not defend the word because it is precise or because another file already uses it. Replace it, then sweep every other place it appears (Rule 6 first).

## Rule 6: Before renaming a term, decide whether it is prose or a structural name

A word that reads like jargon may be an **identifier** other files are required to match. Renaming one side of that silently desyncs the set.

**The test**: does any other file's *content* have to contain this exact string to stay correct? If yes, it is structural.

Structural names include: table column headers, fixed section names a template mandates, frontmatter keys, enum values, and cross-referenced shorthand (`G1` / `G2` / `G3`).

| | 例（本 repo） | 怎麼處理 |
|---|---|---|
| **普通詞** | `gate` —— 只是 tooling 文件裡的段名標籤, 沒有別的檔案需要對上它 | 直接全域換掉 |
| **結構性名稱** | `判準` —— userflow 步驟表的欄位名, 規範 §5.3 定義 + 11 份 userflow 檔實際有這一欄 | 只能**整套**遷移, 或不動並說明理由 |

For a structural name there are only two honest options: do the **whole** migration (the guideline that defines it + every file that carries it + the tools that generate it + any doc that describes the format), or leave it and say why. Rewording only the prose uses while the identifier stays is also legitimate and often the right call — just make it a deliberate, reported split, never a silent one.

本 repo 的實例：`判準` → `判斷依據` 是照第一條做的整套遷移 —— [USERFLOW-WRITING-GUIDELINES.md](../../../specs/docs/USERFLOW-WRITING-GUIDELINES.md)（欄位定義 + 範例表）、11 份 userflow 的表頭、[CLAUDE.md](../../../CLAUDE.md) 的格式描述、產生這張表的 `/draft-flow` 與 `/output-flow`, 共 32 處 / 15 檔一次改完。漏掉任何一邊, 下次產出的表頭就會跟既有檔案對不上。

Before any rename, check for cross-references: `grep` the shorthand and the full term across the whole repo, not just the file you are editing.

## Rule 7: Match the structure that already exists

When adding a file to an existing set, copy the shape of its nearest siblings instead of importing a structure from elsewhere.

1. **Survey first**: list the headings of 3–4 existing files of the same kind (`grep -n '^## ' <files>`). The dominant pattern is the house style, even when no document states it.
2. **Reuse the section names verbatim**, including their language and punctuation. A new name for an existing section reads as a new concept.
3. **Keep fixed positions fixed.** If entry conditions always live in the first step and hand-off always sits second-to-last, put them there — readers navigate by position.
4. **Do not renumber existing steps** when restructuring; other files link by number (「見 Step 3」).

## Rule 8: Verify before you claim

- **Every relative link must resolve.** Compute the path depth and check the target exists; do not trust a counted `../`.
- **Never attribute a rule to a file that does not contain it.** If you write 「這條沿用 CLAUDE.md」, grep CLAUDE.md for it first. A confident, wrong citation is worse than no citation — the next reader inherits it.
- **After a term sweep, grep for leftovers** across the whole tree, and confirm the cross-references you rewrote still point somewhere real.

## Self-check before output

1. Any `,` `;` `:` in prose without a trailing space? Fix it.
2. Any CJK character directly touching an English word or number? Add a space.
3. Did any rule leak into code, URLs, or timestamps? Revert those.
4. Any borrowed term the reader has to decode (`gate`, `lens`, `requirements`)? Check whether a plain word already exists in the sibling files, then use that one — one concept, one word.
5. Renaming something? Confirm it is prose, not a structural name other files must match (Rule 6). If structural, either sweep everything or leave it and say so.
6. New file in an existing set? Its headings should match the siblings' shape, not a structure imported from elsewhere.
7. Every relative link resolves, and every 「沿用 X」 citation is actually in X.
