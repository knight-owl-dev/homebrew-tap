#!/bin/bash
# Update a formula manifest with a new version and checksums from GitHub release
#
# Usage:
#   ./scripts/update-formula.sh <formula-name> <version>
#
# Example:
#   ./scripts/update-formula.sh keystone-cli 0.3.0
#
# Requirements:
#   - gh CLI installed and authenticated
#   - Release must include checksums.txt with SHA256 hashes

set -e

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <formula-name> <version>"
    echo "Example: $0 keystone-cli 0.3.0"
    exit 1
fi

FORMULA_NAME="$1"
NEW_VERSION="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
MANIFEST_FILE="${REPO_DIR}/Manifests/${FORMULA_NAME}.rb"

# Validate manifest exists
if [[ ! -f "${MANIFEST_FILE}" ]]; then
    echo "Error: Manifest not found: ${MANIFEST_FILE}"
    exit 1
fi

# Extract REPO and TAG_PREFIX from manifest
REPO=$(grep -E '^\s*REPO\s*=' "${MANIFEST_FILE}" | sed 's/.*"\(.*\)".*/\1/')
TAG_PREFIX=$(grep -E '^\s*TAG_PREFIX\s*=' "${MANIFEST_FILE}" | sed 's/.*"\(.*\)".*/\1/')

if [[ -z "${REPO}" ]]; then
    echo "Error: Could not extract REPO from manifest"
    exit 1
fi

TAG="${TAG_PREFIX}${NEW_VERSION}"
echo "Updating ${FORMULA_NAME} to version ${NEW_VERSION}"
echo "Repository: ${REPO}"
echo "Release tag: ${TAG}"
echo ""

# Fetch checksums.txt from release
echo "Fetching checksums.txt from release..."
CHECKSUMS=$(gh release download "${TAG}" --repo "${REPO}" --pattern "checksums.txt" --output - 2>/dev/null) || {
    echo "Error: Failed to download checksums.txt from release ${TAG}"
    echo "Make sure the release exists and includes checksums.txt"
    exit 1
}

if [[ -z "${CHECKSUMS}" ]]; then
    echo "Error: checksums.txt is empty"
    exit 1
fi

echo "Checksums found:"
echo "${CHECKSUMS}"
echo ""

# Parse checksums and update manifest
# Format: <sha256>  <filename> (two spaces, GNU coreutils format)
PLATFORMS=("osx-arm64" "osx-x64" "linux-arm64" "linux-x64")

for platform in "${PLATFORMS[@]}"; do
    # Find checksum for this platform
    sha=$(echo "${CHECKSUMS}" | grep "_${platform}\.tar\.gz" | awk '{print $1}')

    if [[ -z "${sha}" ]]; then
        echo "Warning: No checksum found for platform ${platform}"
        continue
    fi

    echo "Updating ${platform}: ${sha}"

    # Update SHA256 line in manifest (preserve alignment spacing)
    sed -i '' "s/\(\"${platform}\"[[:space:]]*=>[[:space:]]*\"\)[a-f0-9]\{64\}\"/\1${sha}\"/" "${MANIFEST_FILE}"
done

# Update VERSION
echo "Updating VERSION to ${NEW_VERSION}"
sed -i '' "s/VERSION = \".*\"/VERSION = \"${NEW_VERSION}\"/" "${MANIFEST_FILE}"

echo ""
echo "Manifest updated: ${MANIFEST_FILE}"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff Manifests/${FORMULA_NAME}.rb"
echo "  2. Test locally:   ./scripts/dev-tap.sh enable && brew reinstall --build-from-source ${FORMULA_NAME}"
echo "  3. Commit:         git add Manifests/${FORMULA_NAME}.rb && git commit -m 'Update ${FORMULA_NAME} to ${NEW_VERSION}'"
