# Formula Sync

Sync formula versions with their latest GitHub releases.

## Instructions

### Step 1: Gather Formula Information

For each `.rb` file in the `Manifests/` directory:

1. Read the manifest to extract:
   - `VERSION` - current version
   - `REPO` - GitHub repository (e.g., `knight-owl-dev/keystone-cli`)
   - `TAG_PREFIX` - release tag prefix (usually `v`)

2. Use `gh release list --repo <repo> --limit 1` to get the latest release tag

3. Compare current version with latest release version (strip TAG_PREFIX from release tag)

### Step 2: Validate Release Structure

For each formula that needs an update:

1. Get release assets: `gh release view <tag> --repo <repo> --json assets`

2. Verify `checksums.txt` exists in the release assets (required for update script)

3. Extract target platforms from asset filenames (pattern: `*_<version>_<platform>.tar.gz`)

4. Compare manifest platforms vs release platforms:
   - **Missing from release**: Platforms in manifest but not in release (ERROR - cannot update)
   - **New in release**: Platforms in release but not in manifest (INFO - can add later)

### Step 3: Review Release Notes

For each formula that needs an update:

1. Fetch release notes: `gh release view <tag> --repo <repo> --json body --jq .body`

2. Read the corresponding `Formula/<name>.rb` to understand the install block

3. Check release notes for changes that could affect the formula:
   - Files added or removed from the archive
   - Renamed binaries or changed structure
   - New dependencies or requirements
   - Breaking changes

4. Flag concerns with ⚠️ - these may require manual formula updates beyond the manifest

### Step 4: Generate Report

```plain
Formula Sync Report
===================

<formula-name>
  Current: <current-version>
  Latest:  <latest-version>
  Status:  UP TO DATE | NEEDS UPDATE | ERROR

  Platforms:
    In manifest: osx-arm64, osx-x64, linux-arm64, linux-x64
    In release:  osx-arm64, osx-x64, linux-arm64, linux-x64

  Release notes review:
    ✓ No issues detected
    -- or --
    ⚠ <concern description>

...
```

### Step 5: Ask User Which Formulas to Update

If any formulas need updates (and have no errors), use AskUserQuestion:

- Include "All outdated formulas" option
- Individual options for each outdated formula
- Note any warnings in the option descriptions
- Use multiSelect

If all formulas are up to date, inform the user and stop.

### Step 6: Branch Setup

1. Check current branch: `git branch --show-current`

2. If on `main`:
   - Check if `formula-update` branch exists: `git branch --list formula-update`
   - If exists, ask user: "Use existing" / "Delete and recreate" / "Different name"
   - If not exists, create it: `git checkout -b formula-update`

3. If on a feature branch, ask: "Continue on current branch" / "Switch to main first"

### Step 7: Update Each Formula

For each formula the user confirmed to update:

1. If there were release note warnings, remind the user and ask if they want to review the formula's install block first

2. Run the update script:

   ```bash
   ./scripts/update-formula.sh <formula-name> <version>
   ```

3. Show the changes:

   ```bash
   git diff Manifests/<formula-name>.rb
   ```

4. Ask user whether to test locally or skip:
   - **Test locally**: Warn this will reinstall the formula

     ```bash
     ./scripts/dev-tap.sh enable
     brew reinstall --build-from-source <formula-name>
     brew test <formula-name>
     ./scripts/dev-tap.sh disable
     ```

   - **Skip testing**: CI will test on PR

5. Ask for confirmation before committing

6. If confirmed:

   ```bash
   git add Manifests/<formula-name>.rb
   git commit -m "Update <formula-name> to <version>"
   ```

7. If test fails or user declines, revert:

   ```bash
   git checkout -- Manifests/<formula-name>.rb
   ```

### Step 8: Summary

After all updates:

- List successfully updated formulas
- List skipped or failed formulas
- Note any new platforms available in releases
- Remind user to push and create PR if updates were made
