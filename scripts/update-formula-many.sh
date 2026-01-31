#!/usr/bin/env bash
set -euo pipefail

# Update one or more formulas to specified or latest versions
#
# Usage:
#   ./scripts/update-formula-many.sh                    # Update all formulas to latest
#   ./scripts/update-formula-many.sh keystone-cli       # Update keystone-cli to latest
#   ./scripts/update-formula-many.sh keystone-cli:0.2.0 # Update keystone-cli to 0.2.0
#   ./scripts/update-formula-many.sh pkg1 pkg2:1.0.0    # Update pkg1 to latest, pkg2 to 1.0.0
#
# Requirements:
#   - gh CLI installed and authenticated

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
MANIFESTS_DIR="${REPO_DIR}/Manifests"

# Get current version from a manifest file
get_current_version() {
    local manifest_file="$1"
    local output
    output=$(grep -E '^\s*VERSION\s*=' "${manifest_file}" || true)
    output="${output#*\"}"
    echo "${output%\"*}"
}

# Get latest version from GitHub releases
get_latest_version() {
    local manifest_file="$1"
    local repo tag_prefix tag_name version output

    output=$(grep -E '^\s*REPO\s*=' "${manifest_file}" || true)
    repo="${output#*\"}"
    repo="${repo%\"*}"

    output=$(grep -E '^\s*TAG_PREFIX\s*=' "${manifest_file}" || true)
    tag_prefix="${output#*\"}"
    tag_prefix="${tag_prefix%\"*}"

    if [[ -z "${repo}" ]]; then
        echo "Error: Could not extract REPO from manifest" >&2
        return 1
    fi

    tag_name=$(gh release view --repo "${repo}" --json tagName --jq '.tagName' 2>/dev/null) || {
        echo "Error: Failed to fetch latest release from ${repo}" >&2
        return 1
    }

    # Strip tag prefix to get version
    version="${tag_name#"${tag_prefix}"}"
    echo "${version}"
}

# Validate formula name (alphanumeric and hyphens only)
validate_formula_name() {
    local name="$1"
    if [[ ! "${name}" =~ ^[A-Za-z0-9-]+$ ]]; then
        echo "Error: Invalid formula name: ${name}" >&2
        return 1
    fi
}

# Validate version string (semver-like: digits and dots)
validate_version() {
    local version="$1"
    if [[ ! "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.]+)?$ ]]; then
        echo "Error: Invalid version format: ${version}" >&2
        return 1
    fi
}

# Parse a formula spec (formula or formula:version)
parse_spec() {
    local spec="$1"
    local formula version

    if [[ "${spec}" == *:* ]]; then
        formula="${spec%%:*}"
        version="${spec#*:}"
    else
        formula="${spec}"
        version=""
    fi

    echo "${formula} ${version}"
}

# Update a single formula
update_formula() {
    local formula="$1"
    local version="$2"
    local manifest_file="${MANIFESTS_DIR}/${formula}.rb"

    # Validate formula exists
    if [[ ! -f "${manifest_file}" ]]; then
        echo "Error: Manifest not found: ${manifest_file}"
        return 1
    fi

    # Get current version
    local current_version
    current_version=$(get_current_version "${manifest_file}")

    # If no version specified, get latest
    if [[ -z "${version}" ]]; then
        echo "Fetching latest version for ${formula}..."
        # shellcheck disable=SC2310
        version=$(get_latest_version "${manifest_file}") || return 1
    fi

    # Validate version format
    # shellcheck disable=SC2310
    validate_version "${version}" || return 1

    # Check if already at target version
    if [[ "${current_version}" == "${version}" ]]; then
        echo "✓ ${formula} is already at version ${version}"
        return 0
    fi

    echo "Updating ${formula}: ${current_version} → ${version}"
    "${SCRIPT_DIR}/update-formula.sh" "${formula}" "${version}"
}

# Main logic
main() {
    local formulas=()

    if [[ $# -eq 0 ]]; then
        # No arguments: discover all manifests
        echo "Discovering formulas in ${MANIFESTS_DIR}..."
        for manifest in "${MANIFESTS_DIR}"/*.rb; do
            if [[ -f "${manifest}" ]]; then
                formula=$(basename "${manifest}" .rb)
                formulas+=("${formula}")
            fi
        done

        if [[ ${#formulas[@]} -eq 0 ]]; then
            echo "No manifests found in ${MANIFESTS_DIR}"
            exit 0
        fi

        echo "Found ${#formulas[@]} formula(s): ${formulas[*]}"
        echo ""
    else
        # Arguments provided: parse specs
        for spec in "$@"; do
            local parsed
            parsed=$(parse_spec "${spec}")
            read -r formula version <<< "${parsed}"
            # shellcheck disable=SC2310
            validate_formula_name "${formula}" || exit 1
            if [[ -n "${version}" ]]; then
                # shellcheck disable=SC2310
                validate_version "${version}" || exit 1
            fi
            formulas+=("${spec}")
        done
    fi

    # Process each formula
    local updated=0
    local failed=0

    for spec in "${formulas[@]}"; do
        local parsed
        parsed=$(parse_spec "${spec}")
        read -r formula version <<< "${parsed}"
        echo "----------------------------------------"
        # shellcheck disable=SC2310
        if update_formula "${formula}" "${version}"; then
            ((updated++)) || true
        else
            ((failed++)) || true
            echo "Failed to update ${formula}"
        fi
        echo ""
    done

    echo "========================================"
    echo "Summary: ${updated} formula(s) processed, ${failed} failed"

    if [[ ${failed} -gt 0 ]]; then
        exit 1
    fi
}

main "$@"
