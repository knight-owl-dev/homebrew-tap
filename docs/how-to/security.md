# How to Secure Workflows and Scripts

This guide documents security best practices for GitHub Actions workflows and shell scripts in this repository.

## Shell Style

This repository follows Homebrew's shell style for all shell code, including workflow `run:` blocks.
Homebrew enforces style via `brew style`, which uses
[shfmt](https://github.com/Homebrew/brew/blob/master/Library/Homebrew/utils/shfmt.sh) and
[shellcheck](https://www.shellcheck.net/) under the hood.
Run `brew style --fix scripts/` before committing shell script changes.

Key style requirements:

- Use `"${var}"` instead of `"$var"` (brace-wrapped variables)
- Use `then` and `do` on new lines (not `if ...; then` or `for ...; do`)
- Use 2-space indentation (no tabs)
- See the [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook) for general Homebrew conventions

## GitHub Actions Security

### Script Injection Prevention

**Problem**: Direct interpolation of GitHub expressions (`${{ }}`) in shell blocks can lead to script injection if the value contains shell metacharacters.

**Solution**: Pass expressions through environment variables using `env:` blocks.

| Do                        | Don't                      |
|---------------------------|----------------------------|
| `env:` block + `"${VAR}"` | Direct `${{ }}` in `run:`  |

**Example - Safe pattern** (from `.github/workflows/update-formula.yml`):

```yaml
- name: Build formula arguments
  id: args
  env:
    # Pass untrusted inputs via env vars to prevent script injection
    INPUT_FORMULAS: ${{ inputs.formulas }}
    PAYLOAD_FORMULAS: ${{ github.event.client_payload.formulas }}
  run: |
    if [ -n "${INPUT_FORMULAS}" ]
    then
      echo "formulas=${INPUT_FORMULAS}" >> "${GITHUB_OUTPUT}"
    elif [ -n "${PAYLOAD_FORMULAS}" ]
    then
      echo "formulas=${PAYLOAD_FORMULAS}" >> "${GITHUB_OUTPUT}"
    fi
```

**Example - Unsafe pattern** (avoid):

```yaml
# UNSAFE: Direct interpolation allows injection
- name: Update formulas
  run: |
    ./scripts/update-formula-many.sh ${{ inputs.formulas }}
```

**Note**: When testing for injection vulnerabilities, use benign payloads like `$(whoami)` or `$(id)`,
not destructive commands.

### Input Validation

**Rule**: Validate untrusted inputs before using them. Validation lives in scripts (not workflows)
for testability and reuse.

**Example** (from `scripts/update-formula-many.sh`):

```bash
validate_formula_name() {
  local name="${1}"
  if [[ ! "${name}" =~ ^[A-Za-z0-9-]+$ ]]
  then
    echo "Error: Invalid formula name: ${name}" >&2
    return 1
  fi
}
```

The workflow passes input via `env:` blocks (preventing injection), and the script validates format.

### Least-Privilege Permissions

**Principle**: Explicitly declare permissions at both workflow and job levels.
Only request the minimum permissions needed.

| Workflow/Job             | Permissions                                                              | Purpose                         |
|--------------------------|--------------------------------------------------------------------------|---------------------------------|
| ci.yml test-bot          | `actions: read`, `checks: read`, `contents: read`, `pull-requests: read` | Read-only access for CI testing |
| update-formula.yml       | `contents: read`                                                         | Read repository for building    |

**Example** (from `.github/workflows/ci.yml`):

```yaml
jobs:
  test-bot:
    runs-on: ${{ matrix.os }}
    permissions:
      actions: read
      checks: read
      contents: read
      pull-requests: read
```

### Action Version Pinning

**Rule**: Every `uses:` reference is pinned to a full commit SHA with a semver
version comment. Tag-only and branch-only references are vulnerable to
tag-rewriting and force-push attacks; SHA pinning ensures the exact code that
was audited is what runs. The semver comment lets Dependabot track the current
version and propose clean minor/patch bumps.

| Reference style   | Use when                                              |
|-------------------|-------------------------------------------------------|
| `@<sha> # vX.Y.Z` | Default — action has tagged releases                  |
| `@<sha> # main`   | Fallback — action has no tagged releases upstream     |

**Example** (from `.github/workflows/ci.yml`):

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
```

**Branch-pinned actions**: A few upstream actions publish no tagged releases
(e.g., `Homebrew/actions/setup-homebrew`). Pin these to a specific commit on
the default branch. Dependabot cannot auto-bump branch-SHA pins without tags,
so the [`action-pin-monitor`](../../.github/workflows/action-pin-monitor.yml)
workflow runs weekly and files a deduped issue when any such pin drifts
behind its upstream branch head.

**Enforcement**: `make lint-action` runs `validate-action-pins` (shipped in
the `ci-tools` image), which resolves each pinned SHA against its claimed ref
via the GitHub API. Tag pins fail the lint on mismatch; branch pins emit a
warning noting how many commits they trail the branch head by (branch heads
move, so a lagging pin is informational, not a hard failure).

### Checkout Security

**Rule**: Disable credential persistence when the workflow doesn't need to push.

**Example** (from `.github/workflows/update-formula.yml`):

```yaml
- name: Checkout
  uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
  with:
    persist-credentials: false
```

## Shell Script Security

### Strict Mode

Scripts should start with strict mode to catch errors early:

```bash
set -euo pipefail
```

| Flag          | Meaning                  | Benefit                          |
|---------------|--------------------------|----------------------------------|
| `-e`          | Exit on error            | Prevents silent failures         |
| `-u`          | Error on unset variables | Catches typos and missing inputs |
| `-o pipefail` | Propagate pipe errors    | Catches failures in pipelines    |

**Note**: Some scripts use only `set -e` when they intentionally allow commands like
`grep` to fail (no match) without stopping execution. See individual script headers.
New automation scripts should prefer the full `set -euo pipefail`.

### Input Validation with Allowlists

Validate all external inputs against explicit patterns.
The script should reject invalid input and exit with an error.

| Script                   | Validates    | Pattern                                                      |
|--------------------------|--------------|--------------------------------------------------------------|
| `update-formula-many.sh` | Formula name | `^[A-Za-z0-9-]+$`                                            |
| `update-formula-many.sh` | Version      | `^[0-9]+(\.[0-9]+){1,3}(-[0-9A-Za-z]+([.-][0-9A-Za-z]+)*)?$` |

Version format supports 2-4 numeric segments (e.g., `1.0`, `1.2.3`, `1.2.3.4`) with optional
pre-release suffix (e.g., `-alpha`, `-rc.1`). Build metadata (`+build`) is not supported.

**Example - Formula name validation** (from `scripts/update-formula-many.sh`):

```bash
validate_formula_name() {
  local name="${1}"
  if [[ ! "${name}" =~ ^[A-Za-z0-9-]+$ ]]
  then
    echo "Error: Invalid formula name: ${name}" >&2
    return 1
  fi
}
```

**Example - Version validation** (from `scripts/update-formula-many.sh`):

```bash
validate_version() {
  local version="${1}"
  if [[ ! "${version}" =~ ^[0-9]+(\.[0-9]+){1,3}(-[0-9A-Za-z]+([.-][0-9A-Za-z]+)*)?$ ]]
  then
    echo "Error: Invalid version format: ${version}" >&2
    return 1
  fi
}
```

### Safe Variable Quoting

**Rule**: Always quote variables and use braces per Homebrew style.

| Do               | Don't          |
|------------------|----------------|
| `"${VERSION}"`   | `$VERSION`     |
| `"${formula}"`   | `${formula}`   |

**Example** (from `scripts/update-formula.sh`):

```bash
FORMULA_NAME="$1"
NEW_VERSION="$2"
MANIFEST_FILE="${REPO_DIR}/Manifests/${FORMULA_NAME}.rb"

if [[ ! -f "${MANIFEST_FILE}" ]]
then
  echo "Error: Manifest not found: ${MANIFEST_FILE}"
  exit 1
fi
```

### Unsafe Constructs to Avoid

| Construct         | Problem                  | Alternative                       |
|-------------------|--------------------------|-----------------------------------|
| `eval "$var"`     | Arbitrary code execution | Use case statements or allowlists |
| `${var}` unquoted | Word splitting, globbing | Always quote: `"${var}"`          |
| `` `command` ``   | Harder to read, nest     | Use `$(command)`                  |

## Quick Reference

| Pattern                      | Location                               | Description                    |
|------------------------------|----------------------------------------|--------------------------------|
| `env:` blocks                | `.github/workflows/update-formula.yml` | Safe GitHub expression passing |
| Explicit permissions         | `.github/workflows/ci.yml`             | Least-privilege access         |
| `persist-credentials: false` | `.github/workflows/update-formula.yml` | Checkout security              |
| SHA pin + semver comment     | `.github/workflows/*.yml`              | Supply-chain hardening         |
| `validate-action-pins`       | `Makefile` (`lint-action` target)      | Enforces pin/comment match     |
| `set -euo pipefail`          | `scripts/create-update-pr.sh`          | Strict mode                    |
| `validate_formula_name()`    | `scripts/update-formula-many.sh`       | Formula name validation        |
| `validate_version()`         | `scripts/update-formula-many.sh`       | Version format validation      |

## External Resources

- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook) - Homebrew conventions and style
- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions)
- [Keeping your GitHub Actions and workflows secure](https://securitylab.github.com/resources/github-actions-preventing-pwn-requests/)
- [ShellCheck](https://www.shellcheck.net/) - Static analysis for shell scripts

## See Also

- [CLAUDE.md](../../CLAUDE.md) - Development reference
- [add-formula](add-formula/README.md) - Adding new formulas
- [sync-formula.md](sync-formula.md) - Syncing formula versions
