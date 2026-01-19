# Formula Sync

Sync formula versions with their latest GitHub releases.

## Instructions

### Step 1: Gather Formula Information

For each `.rb` file in the `Formula/` directory:

1. Read the formula file to extract:
   - Current `version`
   - `homepage` URL (this contains the GitHub repo path)
   - All target platforms from URL patterns (e.g., `osx-arm64`, `linux-x64`)

2. Use `gh release list --repo <repo> --limit 1` to get the latest release tag

3. Compare current version with latest release version

### Step 2: Validate Release Structure

For each formula that needs an update:

1. Get release assets: `gh release view <tag> --repo <repo> --json assets`

2. Extract target platforms from asset filenames (pattern: `*_<version>_<platform>-<arch>.tar.gz`)

3. Compare formula targets vs release targets:
   - **Missing from release**: Targets in formula but not in release assets (ERROR - cannot update)
   - **New in release**: Targets in release but not in formula (WARNING - recommend adding)

4. If there are new targets in the release, include them in the report and recommend the user consider adding support for them in the formula.

### Step 3: Generate Report

Present a clear report to the user:

```plain
Formula Sync Report
===================

<formula-name>
  Current: <current-version>
  Latest:  <latest-version>
  Status:  UP TO DATE | NEEDS UPDATE | ERROR

  Targets in formula: osx-arm64, osx-x64, linux-arm64, linux-x64
  Targets in release: osx-arm64, osx-x64, linux-arm64, linux-x64, windows-x64

  ⚠ New targets available: windows-x64
    Consider adding support for these platforms.

...
```

If a formula has missing targets (in formula but not in release), mark it as ERROR and explain it cannot be auto-updated.

### Step 4: Ask User Which Formulas to Update

If any formulas need updates (and have no errors), use AskUserQuestion to ask which ones to update. Include an "All outdated formulas" option and individual options for each outdated formula. Use multiSelect.

If all formulas are up to date, inform the user and stop.

### Step 5: Branch Setup

Before making changes:

1. Check current branch with `git branch --show-current`

2. If on `main`, need to create or switch to an update branch

3. Check if `formula-update` branch exists locally: `git branch --list formula-update`

4. If the branch exists locally, use AskUserQuestion to ask:
   - "Use existing formula-update branch"
   - "Delete and recreate formula-update branch"
   - "Create branch with different name" (if selected, ask for name)

5. If branch doesn't exist, create it: `git checkout -b formula-update`

6. If already on a non-main branch, use AskUserQuestion to ask:
   - "Continue on current branch (show actual **branch-name**)"
   - "Switch to main and create formula-update branch"

### Step 6: Update Each Formula

For each formula the user confirmed to update:

1. Get SHA256 checksums - prefer `checksums.txt` from release if available:
   - `gh release download <tag> --repo <repo> --pattern "checksums.txt" --output -`
   - Parse format: `<sha256>  <filename>` (GNU coreutils format, compatible with `sha256sum -c`)
   - If no checksums.txt found, warn the user that the release is missing checksums.txt and recommend adding one to future releases for efficiency. Then fall back to downloading each tarball and computing: `curl -sL <url> | shasum -a 256`

2. Update the formula file:
   - Update `version` to new version (strip leading 'v' if present)
   - Update each `url` to point to new release assets
   - Update each `sha256` with corresponding checksums

3. Ask the user whether to test locally or skip testing:
   - Use AskUserQuestion with options:
     - "Test locally" - warn that this will reinstall the formula from the tap, affecting their current installation
     - "Skip testing and show diff" - just show the changes without testing (CI will test on PR)

   If user chooses to test locally:
   - `brew install --build-from-source knight-owl-dev/tap/<formula>`
   - `brew test <formula>`

4. Show the user what changed (git diff) and ask for confirmation before committing

5. If confirmed, commit with message: `Update <formula-name> to <version>`

6. If test fails or user declines, revert changes to that formula and continue to next

### Step 7: Summary

After all updates are processed, show a summary:

- Which formulas were successfully updated
- Which formulas failed or were skipped
- Any new platform targets that should be considered for future updates
- Remind user to push the branch and create a PR if any updates were made
