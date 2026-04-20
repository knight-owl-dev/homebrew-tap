#!/usr/bin/env bash
set -euo pipefail

# Install the ci-tools apt package from https://apt.knight-owl.dev.
#
# Usage:
#   ./scripts/install-ci-tools.sh
#
# Verifies the repository's GPG key against the fingerprint published in
# knight-owl-dev/apt so a CDN compromise can't silently swap keys.
# Intended for Debian/Ubuntu CI runners; requires sudo and curl.

# Fingerprint published in https://github.com/knight-owl-dev/apt/blob/main/README.md
EXPECTED_FPR="25F3E04AE420DC2A0F181ADC89B3FD22D2085FDA"
KEYRING="/usr/share/keyrings/knight-owl.gpg"
SOURCES_LIST="/etc/apt/sources.list.d/knight-owl.list"

curl -fsSL https://apt.knight-owl.dev/PUBLIC.KEY |
  sudo gpg --dearmor -o "${KEYRING}"

actual_fpr=$(
  gpg --show-keys --with-colons "${KEYRING}" |
    awk -F: '$1 == "fpr" {print $10; exit}'
)
if [[ "${actual_fpr}" != "${EXPECTED_FPR}" ]]
then
  echo "GPG key fingerprint mismatch:" >&2
  echo "  expected: ${EXPECTED_FPR}" >&2
  echo "  actual:   ${actual_fpr}" >&2
  exit 1
fi

echo "deb [signed-by=${KEYRING}] https://apt.knight-owl.dev stable main" |
  sudo tee "${SOURCES_LIST}" >/dev/null

sudo apt-get update
sudo apt-get install -y ci-tools
