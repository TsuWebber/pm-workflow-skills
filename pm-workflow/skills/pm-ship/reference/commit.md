# Git Commit Skill

## Overview

Create well-structured git commits with conventional commit messages that clearly describe the changes.

This repo is a **Markdown spec knowledge base** on **Gitea** (no application code). Hand-edited areas are
`drafts/`, `archive/`, and repo docs (`index.md`, `README.md`, `CLAUDE.md`). The folders `specs/` (backend
business logic) and `userflows/` are **synced from other repos** — if they appear in staged changes,
flag it to the user before committing rather than assuming it's intended. (Note: `specs/` also holds
front-end-derived business rules and Route Mapping tables added during the 2609 restructure, which are
maintained in this repo; `frontend/` and `routes/` no longer exist — they were merged into `specs/`.)

## Instructions

When committing changes, follow these steps:

1. **Check the current state** - Run these commands in parallel:
   - `git status` to see staged and unstaged changes
   - `git diff --cached` to see what's staged
   - `git diff` to see unstaged changes
   - `git log --oneline -5` to see recent commit style

2. **Do NOT stage changes** - Only commit what is already staged. If there are no staged changes, inform the user and ask them to stage the files they want to commit

3. **Analyze the changes** - Review what's being committed:
   - What files are affected?
   - What's the nature of the change (fix, feature, refactor, docs, etc.)?
   - What's the primary purpose?

4. **Generate a commit message** following this format:

   ```
   <type>(<scope>): <short description>

   <optional body explaining what and why>
   ```

   Types (this repo):
   - `draft(<sprint>)`: 草稿變更 in `drafts/<sprint>/`（例:`draft(2606): 新增疊券規則草稿`）
   - `docs`: 倉庫說明文件 — `index.md`、`README.md`、`CLAUDE.md`、`AUDIT.md`
   - `docs(archive)`: `archive/` 底下的封存 feature（一般只由 `pm-launch archive` 產生變更）
   - `chore`: `.claude/`、`.gitignore` 等工具與設定

5. **Create the commit** using a HEREDOC for proper formatting:

   ```bash
   git commit -m "$(cat <<'EOF'
   type: short description

   Optional longer description.

   EOF
   )"
   ```

6. **Verify success** - Run `git status` to confirm the commit was created

## Guidelines

- Keep the first line under 72 characters
- Use imperative mood ("add feature" not "added feature")
- Focus on WHY the change was made, not just WHAT changed
- Don't include file lists in the message - git tracks that
- Match the style of recent commits in the repo when possible

## Safety

- Never stage changes automatically - only commit what the user has already staged
- Never use `--force` or destructive commands
- Never skip hooks with `--no-verify` unless explicitly asked
- Never amend commits that have been pushed
- If there are no staged changes, inform the user and do not proceed

## NEVER LIST

- Do not contain "Co-Authored" in commit messages
