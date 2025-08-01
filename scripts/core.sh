#!/bin/bash

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
  set_brave_command
  if pgrep -fa "$BRAVE_CMD" | grep -v "$0" >/dev/null; then
    read -rp "⚠️ Brave is currently running. Close it to proceed? [y/N] " response
    case "$response" in
    [yY]*)
      echo "🔻 Closing Brave..."
      pkill -f "$BRAVE_CMD"
      sleep 2
      echo "✅ Brave closed."
      return 0
      ;;
    *)
      echo "❌ Operation cancelled."
      exit 1
      ;;
    esac
  fi
  return 1
}

reopen_brave() {
  read -rp "🔁 Do you want to reopen Brave and restore your previous session? [y/N] " reopen
  case "$reopen" in
  [yY]*)
    echo "🚀 Launching Brave..."
    set_brave_command
    nohup "$BRAVE_CMD" --restore-last-session >/dev/null 2>&1 &
    ;;
  *)
    echo "👍 Brave was not restarted."
    ;;
  esac
}
