# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Homebrew tap for Knight-Owl-Dev packages.

- `Formula/` - Homebrew formula files (static logic)
- `Manifests/` - Auto-generated version and checksum data
- `scripts/` - Development and automation scripts
- `docs/how-to/` - Guides for common tasks

## Common Commands

```bash
# Validate formula syntax
brew test-bot --only-tap-syntax

# Test a formula locally (downloads, builds, runs test block)
brew install --build-from-source Formula/keystone-cli.rb
brew test keystone-cli

# Audit a formula for style issues
brew audit --strict --online Formula/keystone-cli.rb
```

## Adding or Updating a Formula

Formulas use a manifest-based structure where version and checksums are stored in `Manifests/<name>.rb` and the formula logic is in `Formula/<name>.rb`.

- **Adding a new formula**: See [docs/how-to/add-formula.md](docs/how-to/add-formula.md)
- **Updating to a new version**: See [docs/how-to/sync-formula.md](docs/how-to/sync-formula.md)

Quick update command:

```bash
./scripts/update-formula.sh <formula-name> <version>
```

## Local Development

To test formula changes locally, use the dev-tap script to point Homebrew at your local checkout:

```bash
./scripts/dev-tap.sh enable   # Point tap to local repo, enable dev mode
./scripts/dev-tap.sh disable  # Restore original tap, disable dev mode
./scripts/dev-tap.sh status   # Check current tap configuration
```

While enabled, run `brew reinstall --build-from-source keystone-cli` to test changes.

## CI/CD

- **tests.yml**: Runs `brew test-bot` on PRs and pushes to main (Ubuntu, Intel Mac, ARM Mac)

Note: There is no bottle publishing workflow. Formulas in this tap download pre-built binaries directly from releases, so bottling would be redundant.

## Claude Commands

- **/formula-sync**: Check all formulas against their latest GitHub releases, report which need updates, and interactively update selected formulas with proper testing and individual commits.
- **/pr-create**: Create a pull request from the current branch with an auto-generated title and body based on commits and changes.
