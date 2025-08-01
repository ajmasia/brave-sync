#!/bin/bash

source "$HOME/.local/share/brave-sync/scripts/env.sh"
source "$HOME/.local/share/brave-sync/scripts//core.sh"
source "$HOME/.local/share/brave-sync/scripts/functions.sh"

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
