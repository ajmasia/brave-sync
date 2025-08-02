#!/usr/bin/env bash

# Fallback to install path if not in DEV_MODE
if [ "${DEV_MODE:-false}" = true ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  ROOT_DIR="$HOME/.local/share/brave-sync"
fi

source "$ROOT_DIR/bootstrap.sh"

if [ "${DEV_MODE:-false}" = true ]; then
  echo "⚙️  Running in DEVELOPMENT mode"
fi

include_script "scripts/env.sh"
include_script "scripts/help.sh"

case "$1" in
backup)
  bash "$ROOT_DIR/scripts/sync.sh" backup
  ;;
restore)
  bash "$ROOT_DIR/scripts/sync.sh" restore
  ;;
config)
  bash "$ROOT_DIR/scripts/config.sh"
  ;;
update)
  bash "$ROOT_DIR/scripts/update.sh"
  ;;
uninstall)
  bash "$ROOT_DIR/scripts/uninstall.sh"
  ;;
version)
  bash "$ROOT_DIR/scripts/version.sh"
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
