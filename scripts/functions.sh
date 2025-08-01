#!/bin/bash

# Sets the correct Brave command based on what's installed
set_brave_command() {
  if command -v brave-browser >/dev/null 2>&1; then
    BRAVE_CMD="brave-browser"
  elif command -v brave >/dev/null 2>&1; then
    BRAVE_CMD="brave"
  else
    echo "❌ Brave is not installed or not found in PATH."
    exit 1
  fi
}

# Returns true if Brave is running (either variant)
is_brave_running() {
  pgrep -x brave-browser >/dev/null 2>&1 || pgrep -x brave >/dev/null 2>&1
}

# Kills all Brave processes safely
close_brave() {
  echo "🔻 Closing Brave..."
  pgrep -x brave-browser >/dev/null && pkill -x brave-browser
  pgrep -x brave >/dev/null && pkill -x brave
  sleep 2
  echo "✅ Brave has been closed."
}

load_sync_config() {
  CONFIG_FILE="$HOME/.config/brave-sync/config"
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Sync configuration not found: $CONFIG_FILE"
    echo "💡 Run 'brave-sync config' to set your sync folder."
    exit 1
  fi

  source "$CONFIG_FILE"

  if [ -z "$SYNC_DIR" ]; then
    echo "❌ SYNC_DIR is empty in config file."
    echo "💡 Run 'brave-sync config' to fix it."
    exit 1
  fi

  NEXTCLOUD_DIR="$SYNC_DIR"
}
