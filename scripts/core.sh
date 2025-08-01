#!/bin/bash

load_sync_config() {
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Sync configuration not found: $CONFIG_FILE"
    echo "💡 Run 'brave-sync config' to set your sync folder."
    exit 1
  fi

  source "$CONFIG_FILE"

  if [ -z "$SYNC_DIR" ]; then
    echo "❌ SYNC_DIR is empty in config file."
    exit 1
  fi

  NEXTCLOUD_DIR="$SYNC_DIR"
}

check_brave_running() {
  BRAVE_CMD=$(command -v brave-browser || command -v brave)
  if pgrep -fa "$BRAVE_CMD" | grep -v "$0" >/dev/null; then
    read -rp "⚠️ Brave is currently running. Close it to proceed? [y/N] " response
    case "$response" in
    [yY]*)
      echo "🔻 Closing Brave..."
      pkill -f "$BRAVE_CMD"
      sleep 2
      echo "✅ Brave closed."
      ;;
    *)
      echo "❌ Operation cancelled."
      exit 1
      ;;
    esac
  fi
}
