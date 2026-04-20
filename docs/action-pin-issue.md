<!-- markdownlint-disable MD041 — no h1 needed; GitHub injects the issue title -->

## Action Pin Monitor Alert

The scheduled pin check found branch-pinned GitHub Actions whose SHA is behind
the upstream branch head. Dependabot doesn't bump branch-SHA pins, so these
need a manual refresh.

### Stale Pins

$STALE_PINS

### Next Steps

1. Review the [workflow run]($RUN_URL) that produced this report.
2. For each stale pin, resolve the latest upstream SHA —
   `gh api /repos/<owner>/<repo>/commits/<branch> --jq .sha`.
3. Update the `uses:` line in the affected workflow file; keep the
   `# <branch>` comment intact.
4. Open a PR. CI's `make lint-action` validates the new pin via
   `validate-action-pins check`.

See [docs/how-to/security.md](docs/how-to/security.md) for the pinning policy.
