# Create Pull Request

Create a pull request from the current branch with a properly formatted title and body.

## Instructions

### Step 1: Verify Branch State

1. Get current branch: `git branch --show-current`

2. If on `main`, inform the user they need to be on a feature branch and stop.

3. Check if branch has a remote tracking branch and if it needs to be pushed:
   - `git status -sb` to see tracking status
   - If not pushed or behind, ask user if they want to push first

4. Push the branch if needed: `git push -u origin <branch-name>`

### Step 2: Analyze Changes

1. Get the list of commits on this branch not in main:
   - `git log main..<branch> --oneline`

2. Get the diff summary to understand what files changed:
   - `git diff main...<branch> --stat`

3. For each changed formula file, extract:
   - Formula name
   - Version (old vs new if updating)
   - Whether it's a new file or modification

### Step 3: Draft PR Content

Based on the analysis, draft:

**Title format:**

- For single formula update: `Update <formula-name> to <version>`
- For new formula: `Add <formula-name> formula`
- For multiple formulas: `Update formulas: <name1>, <name2>`
- For other changes: Use a concise descriptive title

**Body format** (following `.github/PULL_REQUEST_TEMPLATE.md`):

```markdown
# Summary

<What formula(s) being added/updated and version(s)>

## Changes

<Description of changes based on commit messages and diff analysis>
```

### Step 4: Confirm with User

Present the drafted PR title and body to the user. Use AskUserQuestion to confirm:

- "Create PR with this content"
- "Edit title/body first" (if selected, ask what to change)
- "Cancel"

### Step 5: Create the PR

If confirmed, create the PR and capture the URL:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<body content>
EOF
)"
```

Extract the PR number from the returned URL (format: `https://github.com/<owner>/<repo>/pull/<number>`).

### Step 6: Report Result

Show the user:

- PR URL
- PR number

Then use AskUserQuestion to offer:

- "Open PR in browser" (if selected, run `gh pr view <number> --web`)
- "Done"
