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

### Step 3: Review Release Notes for Formula Integrity

For each formula that needs an update:

1. Fetch release notes: `gh release view <tag> --repo <repo> --json body --jq .body`

2. Review the formula's `install` block to understand what files it expects and how it installs them.

3. Analyze the release notes for changes that could invalidate the formula's install logic:
   - **Files added or removed** from the release archive
   - **Renamed binaries or changed directory structure**
   - **New dependencies** or runtime requirements
   - **Breaking changes** to CLI invocation or behavior

4. Flag any concerns with ⚠️ in the report. These indicate the formula may need manual updates to the `install` block beyond syncing URLs and checksums.

Note: This is a best-effort check based on release notes. If release notes are sparse or missing, note that in the report and recommend the user verify the install block manually after updating.

### Step 4: Generate Report

Present a clear report to the user:

```plain
Formula Sync Report
===================

<formula-name>
  Current: <current-version>
  Latest:  <latest-version>
  Status:  UP TO DATE | NEEDS UPDATE | ERROR

  Targets:
    In formula: osx-arm64, osx-x64, linux-arm64, linux-x64
    In release: osx-arm64, osx-x64, linux-arm64, linux-x64, windows-x64
    ⚠ New targets available: windows-x64

  Formula integrity:
    ✓ No issues detected
    -- or --
    ⚠ Release notes mention new config file - verify install block
    ⚠ Release notes sparse - recommend manual verification

...
```

- **ERROR status**: Formula has targets missing from release; cannot auto-update.
- **⚠ warnings**: Formula can be updated, but user should verify install block is still correct.

### Step 5: Ask User Which Formulas to Update

If any formulas need updates (and have no errors), use AskUserQuestion to ask which ones to update. Include an "All outdated formulas" option and individual options for each outdated formula. Use multiSelect.

If a formula has integrity warnings, note this in the options so the user is aware manual verification may be needed.

If all formulas are up to date, inform the user and stop.

### Step 6: Branch Setup

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

### Step 7: Update Each Formula

For each formula the user confirmed to update:

1. If this formula had integrity warnings, remind the user before proceeding and ask if they want to review/edit the install block first.

2. Get SHA256 checksums - prefer `checksums.txt` from release if available:
   - `gh release download <tag> --repo <repo> --pattern "checksums.txt" --output -`
   - Parse format: `<sha256>  <filename>` (GNU coreutils format, compatible with `sha256sum -c`)
   - If no checksums.txt found, warn the user that the release is missing checksums.txt and recommend adding one to future releases for efficiency. Then fall back to downloading each tarball and computing: `curl -sL <url> | shasum -a 256`

3. Update the formula file:
   - Update `version` to new version (strip leading 'v' if present)
   - Update each `url` to point to new release assets
   - Update each `sha256` with corresponding checksums

4. Ask the user whether to test locally or skip testing:
   - Use AskUserQuestion with options:
     - "Test locally" - warn that this will reinstall the formula from the tap, affecting their current installation
     - "Skip testing and show diff" - just show the changes without testing (CI will test on PR)

   If user chooses to test locally:
   - `brew install --build-from-source knight-owl-dev/tap/<formula>`
   - `brew test <formula>`

5. Show the user what changed (git diff) and ask for confirmation before committing

6. If confirmed, commit with message: `Update <formula-name> to <version>`

7. If test fails or user declines, revert changes to that formula and continue to next

### Step 8: Summary

After all updates are processed, show a summary:

- Which formulas were successfully updated
- Which formulas failed or were skipped
- Any new platform targets that should be considered for future updates
- Remind user to push the branch and create a PR if any updates were made
