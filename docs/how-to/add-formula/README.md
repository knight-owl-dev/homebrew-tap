# How to Add a New Formula

This guide walks through adding a new formula to the tap using the manifest-based structure.

## Prerequisites

- The package must have GitHub releases with pre-built binaries
- Each release must include a `checksums.txt` file with SHA256 hashes
- Binary naming convention: `<name>_<version>_<platform>.tar.gz`
  - Platforms: `osx-arm64`, `osx-x64`, `linux-arm64`, `linux-x64`

## Step 1: Create the Manifest

Create `Manifests/<formula-name>.rb` using the
[manifest template](manifest-template.rb.md).

**Notes:**

- Module name must be PascalCase version of the formula name plus `Manifest` (e.g., `KeystoneCliManifest`)
- `TAG_PREFIX` is typically `"v"` for tags like `v1.0.0`, or `""` for tags like `1.0.0`
- `ASSET_TEMPLATE` uses Ruby `format()` syntax with `%<version>s` and `%<platform>s` placeholders

## Step 2: Create the Formula

Create `Formula/<formula-name>.rb` using the
[formula template](formula-template.rb.md).

**Notes:**

- Class name must be PascalCase version of the formula name (e.g., `KeystoneCli` for `keystone-cli`)
- The `install` block depends on what's in the release archive
- The `test` block should run a simple command that verifies the binary works

## Step 3: Get Initial Checksums

Use the update script to populate the SHA256 values:

```bash
./scripts/update-formula.sh <formula-name> <version>
```

This will fail if the manifest has placeholder SHA256 values, so first set them to any valid 64-character hex string (e.g., `0000000000000000000000000000000000000000000000000000000000000000`), then run the script to update them with the real checksums.

## Step 4: Test Locally

```bash
# Point tap to local repo
./scripts/dev-tap.sh enable

# Install and test
brew install --build-from-source <formula-name>
brew test <formula-name>

# Check for style issues
brew audit --strict <formula-name>

# Restore tap when done
./scripts/dev-tap.sh disable
```

## Step 5: Commit and PR

```bash
git add Manifests/<formula-name>.rb Formula/<formula-name>.rb
git commit -m "Add <formula-name> formula"
```

## After Adding

Once merged, the formula will be automatically updated when new releases are published:

- The `update-formula` workflow discovers all manifests in `Manifests/`
- When triggered (manually or via `repository_dispatch`), it updates versions and checksums
- See [sync-formula.md](../sync-formula.md) for details on automated updates

## Example: keystone-cli

See the existing implementation:

- [`Manifests/keystone-cli.rb`](../../../Manifests/keystone-cli.rb)
- [`Formula/keystone-cli.rb`](../../../Formula/keystone-cli.rb)
