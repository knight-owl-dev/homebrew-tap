# How to Add a New Formula

This guide walks through adding a new formula to the tap using the manifest-based structure.

## Prerequisites

- The package must have GitHub releases with pre-built binaries
- Each release must include a `checksums.txt` file with SHA256 hashes
- Binary naming convention: `<name>_<version>_<platform>.tar.gz`
  - Platforms: `osx-arm64`, `osx-x64`, `linux-arm64`, `linux-x64`

## Step 1: Create the Manifest

Create `Manifests/<formula-name>.rb`:

```ruby
# AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
# Update with: scripts/update-formula.sh <formula-name> <version>

module <FormulaName>Manifest
  VERSION = "<version>"
  REPO = "<org>/<repo>"
  TAG_PREFIX = "v"
  ASSET_TEMPLATE = "<name>_%{version}_%{platform}.tar.gz"

  SHA256 = {
    "osx-arm64" => "<sha256>",
    "osx-x64" => "<sha256>",
    "linux-arm64" => "<sha256>",
    "linux-x64" => "<sha256>",
  }.freeze
end
```

**Notes:**

- Module name must be PascalCase version of the formula name plus `Manifest` (e.g., `KeystoneCliManifest`)
- `TAG_PREFIX` is typically `"v"` for tags like `v1.0.0`, or `""` for tags like `1.0.0`
- `ASSET_TEMPLATE` uses Ruby string formatting with `%{version}` and `%{platform}` placeholders

## Step 2: Create the Formula

Create `Formula/<formula-name>.rb`:

```ruby
require_relative "../Manifests/<formula-name>"

class <FormulaName> < Formula
  include <FormulaName>Manifest

  desc "<description>"
  homepage "https://github.com/#{REPO}"
  version VERSION
  license "<license>"

  on_macos do
    on_arm do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{ASSET_TEMPLATE % {version: VERSION, platform: 'osx-arm64'}}"
      sha256 SHA256["osx-arm64"]
    end
    on_intel do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{ASSET_TEMPLATE % {version: VERSION, platform: 'osx-x64'}}"
      sha256 SHA256["osx-x64"]
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{ASSET_TEMPLATE % {version: VERSION, platform: 'linux-arm64'}}"
      sha256 SHA256["linux-arm64"]
    end
    on_intel do
      url "https://github.com/#{REPO}/releases/download/#{TAG_PREFIX}#{VERSION}/#{ASSET_TEMPLATE % {version: VERSION, platform: 'linux-x64'}}"
      sha256 SHA256["linux-x64"]
    end
  end

  def install
    # Customize based on archive contents
    bin.install "<binary-name>"
    # Optional: man pages, config files, etc.
  end

  test do
    system bin/"<binary-name>", "--version"
  end
end
```

**Notes:**

- Class name must be PascalCase version of the formula name (e.g., `KeystoneCli` for `keystone-cli`)
- The `install` block depends on what's in the release archive
- The `test` block should run a simple command that verifies the binary works

## Step 3: Get Initial Checksums

Use the update script to populate the SHA256 values:

```bash
./scripts/update-formula.sh <formula-name> <version>
```

This will fail if the manifest has placeholder SHA256 values, so first set them to any valid 64-character hex string, then run the script to update them.

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
- See [sync-formula.md](sync-formula.md) for details on automated updates

## Example: keystone-cli

See the existing implementation:

- [`Manifests/keystone-cli.rb`](../../Manifests/keystone-cli.rb)
- [`Formula/keystone-cli.rb`](../../Formula/keystone-cli.rb)
