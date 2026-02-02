.PHONY: help lint lint-brew lint-action lint-md lint-fix lint-brew-fix lint-md-fix

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

lint: lint-brew lint-action lint-md ## Run all linters

lint-brew: ## Check Ruby style (brew style)
	brew style Formula/ Manifests/ scripts/

lint-action: ## Check GitHub Actions (actionlint)
	actionlint

lint-md: ## Check Markdown (markdownlint)
	markdownlint-cli2 "**/*.md"

lint-fix: lint-brew-fix lint-md-fix ## Fix all auto-fixable issues

lint-brew-fix: ## Fix Ruby style issues
	brew style --fix Formula/ Manifests/ scripts/

lint-md-fix: ## Fix Markdown issues
	markdownlint-cli2 --fix "**/*.md"
