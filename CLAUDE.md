# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Homebrew tap for Knight-Owl-Dev packages.

- `artifacts/` - Local intermediate files (gitignored)
- `docs/how-to/` - Guides for common tasks
- `Formula/` - Homebrew formula files (static logic)
- `Manifests/` - Auto-generated version and checksum data
- `scripts/` - Development and automation scripts

## Common Commands

```bash
# Run all linters (mirrors CI)
make lint

# Auto-fix linting issues where possible
make lint-fix

# Validate formula syntax
brew test-bot --only-tap-syntax

# Test a formula locally (downloads, builds, runs test block)
brew install --build-from-source Formula/keystone-cli.rb
brew test keystone-cli

# Audit a formula for style issues
brew audit --strict --online Formula/keystone-cli.rb
```

### Makefile Targets

| Target          | Description                                            |
| --------------- | ------------------------------------------------------ |
| `lint`          | Run all linters (brew style, actionlint, markdownlint) |
| `lint-brew`     | Check Ruby style in Formula/, Manifests/, scripts/     |
| `lint-action`   | Check GitHub Actions workflow syntax                   |
| `lint-md`       | Check Markdown files                                   |
| `lint-fix`      | Auto-fix brew style and markdownlint issues            |
| `lint-brew-fix` | Auto-fix brew style issues                             |
| `lint-md-fix`   | Auto-fix markdownlint issues                           |

## Adding or Updating a Formula

Formulas use a manifest-based structure where version and checksums are stored in `Manifests/<name>.rb` and the formula logic is in `Formula/<name>.rb`.

- **Adding a new formula**: See [docs/how-to/add-formula.md](docs/how-to/add-formula.md)
- **Updating to a new version**: See [docs/how-to/sync-formula.md](docs/how-to/sync-formula.md)
- **Security best practices**: See [docs/how-to/security.md](docs/how-to/security.md) — **follow strictly when writing workflows or scripts**. When testing for injection vulnerabilities, use benign payloads like `$(whoami)` or `$(id)`, not destructive commands.

Quick update commands:

```bash
# Update single formula to specific version
./scripts/update-formula.sh <formula-name> <version>

# Update all formulas to latest versions
./scripts/update-formula-many.sh

# Update specific formulas (latest or pinned version)
./scripts/update-formula-many.sh <formula> <formula:version>
```

## Local Development

To test formula changes locally, use the dev-tap script to point Homebrew at your local checkout:

```bash
./scripts/dev-tap.sh enable   # Point tap to local repo, enable dev mode
./scripts/dev-tap.sh disable  # Restore original tap, disable dev mode
./scripts/dev-tap.sh status   # Check current tap configuration
```

While enabled, run `brew reinstall --build-from-source keystone-cli` to test changes.

## Shell Script Conventions

Use `#!/usr/bin/env bash` for portability, and prefer `set -euo pipefail` on line 2:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Script description...
```

See [docs/how-to/security.md](docs/how-to/security.md) for when `set -e` alone is acceptable.

Use `brew style --fix` for formatting (not standalone shfmt):

```bash
brew style --fix scripts/
```

## CI/CD

- **ci.yml**: Runs linting (actionlint, markdownlint) and `brew test-bot` on PRs and pushes to main
- **update-formula.yml**: Updates formulas to latest versions, creates PR with auto-merge
  - Trigger manually via Actions tab, or via `repository_dispatch` from upstream repos
  - Requires `PR_TOKEN` secret (PAT with `repo` scope)

Note: There is no bottle publishing workflow. Formulas in this tap download pre-built binaries directly from releases, so bottling would be redundant.

## Claude Commands

- **/formula-sync**: Check all formulas against their latest GitHub releases, report which need updates, and interactively update selected formulas with proper testing and individual commits.
- **/pr-create**: Create a pull request from the current branch with an auto-generated title and body based on commits and changes.
