#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

source "$REPO_ROOT/scripts/help.sh"

case "$1" in
backup)
  bash "$REPO_ROOT/scripts/sync.sh" backup
  ;;
restore)
  bash "$REPO_ROOT/scripts/sync.sh" restore
  ;;
config)
  bash "$REPO_ROOT/scripts/config.sh"
  ;;
update)
  bash "$REPO_ROOT/scripts/update.sh"
  ;;
uninstall)
  bash "$REPO_ROOT/scripts/uninstall.sh"
  ;;
version)
  bash "$REPO_ROOT/scripts/version.sh"
  ;;
help | -h | --help | "")
  print_help
  ;;
*)
  echo "❌ Unknown command: $1"
  echo "Run 'brave-sync help' to see available commands."
  exit 1
  ;;
esac
