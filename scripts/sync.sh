#!/bin/bash

echo $(dirname "$0")

source "$(dirname "$0")/../env.sh"
source "$(dirname "$0")/core.sh"
source "$(dirname "$0")/functions.sh"

MODE="$1"
load_sync_config
check_brave_running

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
