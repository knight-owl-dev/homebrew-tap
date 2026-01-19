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

## Maintaining this tap

This repository includes [Claude Code](https://claude.ai/code) integration. Run `/formula-sync` to check for outdated formulas and update them interactively.

For manual updates, see [.claude/commands/formula-sync.md](.claude/commands/formula-sync.md) for the detailed process.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
