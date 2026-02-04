# How to Sync Formula Versions

This guide covers updating formulas when new releases are available.

## Quick Update (Script)

For a single formula with a known version:

```bash
./scripts/update-formula.sh <formula-name> <version>
```

Example:

```bash
./scripts/update-formula.sh keystone-cli 0.3.0
```

The script will:

1. Fetch `checksums.txt` from the GitHub release
2. Update the manifest with new VERSION and SHA256 values
3. Print next steps for testing and committing

## Check for Updates

To see what's outdated, compare manifest versions with latest releases:

```bash
# Get current version from manifest
grep 'VERSION =' Manifests/keystone-cli.rb

# Get latest release from GitHub
gh release list --repo knight-owl-dev/keystone-cli --limit 1
```

## Full Update Workflow

### 1. Update the Manifest

```bash
./scripts/update-formula.sh keystone-cli 0.3.0
```

### 2. Review Changes

```bash
git diff Manifests/keystone-cli.rb
```

Verify:

- VERSION updated correctly
- All SHA256 values changed
- No unexpected modifications

### 3. Test Locally (Optional)

```bash
# Enable local tap
./scripts/dev-tap.sh enable

# Reinstall with new version
brew reinstall --build-from-source keystone-cli

# Run tests
brew test keystone-cli

# Restore tap
./scripts/dev-tap.sh disable
```

### 4. Commit

```bash
git add Manifests/keystone-cli.rb
git commit -m "Update keystone-cli to 0.3.0"
```

## Using the Claude Command

The `/formula-sync` command provides an interactive way to check and update formulas:

1. Run `/formula-sync` in Claude Code
2. Review the report showing current vs latest versions
3. Select which formulas to update
4. Claude will run the update script and guide you through testing

## Troubleshooting

### "Failed to download checksums.txt"

The release doesn't include a `checksums.txt` file. This is required for automated updates. Ask the package maintainer to add it to their release workflow.

### SHA256 mismatch after install

The checksums in the manifest don't match the downloaded files. Re-run the update script to fetch fresh checksums:

```bash
./scripts/update-formula.sh <formula-name> <version>
```

### Missing platform in checksums

If a platform is missing from `checksums.txt`, the script will print a warning but continue. You'll need to either:

- Remove that platform from the formula
- Ask the package maintainer to add the missing binary

## Automated Updates

The `update-formula` workflow automates formula updates via GitHub Actions.

### Manual Trigger

1. Go to **Actions** > **Update Formula**
2. Click **Run workflow**
3. Optionally specify formulas (leave empty for all):
   - `keystone-cli` — update to latest version
   - `keystone-cli:0.3.0` — update to specific version
   - `pkg1 pkg2:1.0.0` — update multiple formulas
4. The workflow creates a PR with auto-merge enabled

### Automated Trigger

Package release workflows can trigger this via `repository_dispatch`. Add these steps to your
release workflow:

```yaml
- name: Generate GitHub App token
  id: app-token
  uses: actions/create-github-app-token@v2
  with:
    app-id: ${{ secrets.APP_ID }}
    private-key: ${{ secrets.APP_PRIVATE_KEY }}
    owner: knight-owl-dev
    repositories: homebrew-tap

- name: Trigger Homebrew tap update
  uses: peter-evans/repository-dispatch@v4
  with:
    token: ${{ steps.app-token.outputs.token }}
    repository: knight-owl-dev/homebrew-tap
    event-type: release-published
    client-payload: '{"formulas": "my-formula:${{ needs.release.outputs.version }}"}'
```

Required setup:

1. Install the knight-owl-dev GitHub App on your package's repo
2. Ensure `APP_ID` and `APP_PRIVATE_KEY` org secrets are available to your repo

You can also trigger manually via the `gh` CLI:

```bash
gh api repos/knight-owl-dev/homebrew-tap/dispatches \
  -f event_type=release-published \
  -f client_payload='{"formulas": "keystone-cli:0.3.0"}'
```

### Batch Updates

Update all formulas to their latest versions:

```bash
./scripts/update-formula-many.sh
```

Or update specific formulas:

```bash
./scripts/update-formula-many.sh keystone-cli other-pkg:1.2.0
```
