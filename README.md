# Knight-Owl-Dev Tap

[![Homebrew](https://img.shields.io/badge/install-homebrew-brightgreen)](https://brew.sh)

## Available Formulae

| Formula                                                          | Description                         |
|------------------------------------------------------------------|-------------------------------------|
| [`keystone-cli`](https://github.com/Knight-Owl-Dev/keystone-cli) | Command-line interface for Keystone |

## Installation

```bash
brew install knight-owl-dev/tap/keystone-cli
```

Or tap first, then install:

```bash
brew tap knight-owl-dev/tap
brew install keystone-cli
```

Or in a `Brewfile`:

```ruby
tap "knight-owl-dev/tap"
brew "keystone-cli"
```

## Releasing Updates

This repository uses [Claude Code](https://claude.ai/code) to streamline formula updates.

1. Run `/formula-sync` in Claude Code to check for new releases
2. Follow the prompts to update formulas (downloads checksums, runs tests)
3. Create a PR with `/pr-create`
4. Squash and merge the PR once CI passes

For manual updates, see [.claude/commands/formula-sync.md](.claude/commands/formula-sync.md).

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
