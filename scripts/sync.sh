#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR/.."

source "$REPO_ROOT/env.sh"
source "$REPO_ROOT/functions.sh"
source "$REPO_ROOT/core.sh"

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
