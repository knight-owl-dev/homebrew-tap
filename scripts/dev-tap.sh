#!/bin/bash
# Toggle between local development tap and installed tap
#
# Usage:
#   ./scripts/dev-tap.sh enable   # Point tap to local repo, enable dev mode
#   ./scripts/dev-tap.sh disable  # Restore original tap, disable dev mode
#   ./scripts/dev-tap.sh status   # Show current tap status

set -e

TAP_DIR="$(brew --prefix)/Library/Taps/knight-owl-dev/homebrew-tap"
BACKUP_DIR="/tmp/homebrew-tap.bak"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"

status() {
  echo "Tap directory: ${TAP_DIR}"
  if [[ -L "${TAP_DIR}" ]]
  then
    local target
    target="$(readlink "${TAP_DIR}" 2>/dev/null || true)"
    if [[ -n "${target}" ]]
    then
      echo "Status: DEVELOPMENT (symlinked to ${target})"
    else
      echo "Status: DEVELOPMENT (symlink target unreadable)"
    fi
  elif [[ -d "${TAP_DIR}" ]]
  then
    echo "Status: INSTALLED (normal tap)"
  else
    echo "Status: NOT INSTALLED"
  fi

  if [[ -d "${BACKUP_DIR}" ]]
  then
    echo "Backup: exists at ${BACKUP_DIR}"
  else
    echo "Backup: none"
  fi

  echo -n "Developer mode: "
  local dev_status
  dev_status="$(brew developer 2>/dev/null || true)"
  if echo "${dev_status}" | grep -q "enabled"
  then
    echo "enabled"
  else
    echo "disabled"
  fi
}

enable() {
  if [[ -L "${TAP_DIR}" ]]
  then
    echo "Already in development mode"
    status
    exit 0
  fi

  if [[ -d "${BACKUP_DIR}" ]]
  then
    echo "Error: Backup already exists at ${BACKUP_DIR}"
    echo "Run 'disable' first or remove the backup manually"
    exit 1
  fi

  if [[ -d "${TAP_DIR}" ]]
  then
    echo "Backing up installed tap..."
    mv "${TAP_DIR}" "${BACKUP_DIR}"
  fi

  echo "Linking tap to local repository..."
  ln -s "${REPO_DIR}" "${TAP_DIR}"

  echo "Enabling developer mode..."
  brew developer on

  echo ""
  echo "Development mode enabled."
  echo "Run 'brew reinstall --build-from-source keystone-cli' to test changes."
}

disable() {
  if [[ ! -L "${TAP_DIR}" ]]
  then
    echo "Not in development mode"
    status
    exit 0
  fi

  echo "Removing symlink..."
  rm "${TAP_DIR}"

  if [[ -d "${BACKUP_DIR}" ]]
  then
    echo "Restoring original tap..."
    mv "${BACKUP_DIR}" "${TAP_DIR}"
  else
    echo "Warning: No backup found, tap will need to be reinstalled"
    echo "Run: brew tap knight-owl-dev/tap"
  fi

  echo "Disabling developer mode..."
  brew developer off

  echo ""
  echo "Development mode disabled."
}

case "${1:-}" in
  enable | on)
    enable
    ;;
  disable | off)
    disable
    ;;
  status)
    status
    ;;
  *)
    echo "Usage: $0 {enable|disable|status}"
    echo ""
    echo "Commands:"
    echo "  enable   Point tap to local repo for testing, enable dev mode"
    echo "  disable  Restore original tap, disable dev mode"
    echo "  status   Show current tap configuration"
    exit 1
    ;;
esac
