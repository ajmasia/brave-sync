#!/usr/bin/env bash

# Fallback to install path if not in DEV_MODE
if [ "${DEV_MODE:-false}" = true ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  ROOT_DIR="$HOME/.local/share/brave-sync"
fi

source "$ROOT_DIR/bootstrap.sh"

include_script "scripts/env.sh"
include_script "scripts/core.sh"
include_script "scripts/functions.sh"

set_brave_command

MODE="$1"
load_sync_config

case "$MODE" in
backup)
  run_backup
  ;;
restore)
  run_restore
  ;;
*)
  echo "❌ Invalid mode: $MODE"
  echo "Usage: sync.sh [backup|restore]"
  exit 1
  ;;
esac
