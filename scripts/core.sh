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
    BRAVE_CMD=$(command -v brave-browser || command -v brave)
    nohup "$BRAVE_CMD" --restore-last-session >/dev/null 2>&1 &
    ;;
  *)
    echo "👍 Brave was not restarted."
    ;;
  esac
}

### scripts/functions.sh
#!/bin/bash

run_backup() {
  check_brave_running && BRAVE_WAS_RUNNING=1 || BRAVE_WAS_RUNNING=0

  for ITEM in Bookmarks Extensions "Web Data" Preferences History; do
    if [ -e "$BRAVE_DIR/$ITEM" ]; then
      rsync -av --delete "$BRAVE_DIR/$ITEM" "$NEXTCLOUD_DIR/"
      echo "✅ Backed up: $ITEM"
    else
      echo "⚠️ Skipped (not found): $ITEM"
    fi
  done

  echo "🎉 Backup completed."

  if [ "$BRAVE_WAS_RUNNING" -eq 1 ]; then
    reopen_brave
  fi
}

run_restore() {
  check_brave_running && BRAVE_WAS_RUNNING=1 || BRAVE_WAS_RUNNING=0

  for ITEM in Bookmarks Extensions "Web Data" Preferences History; do
    if [ -e "$NEXTCLOUD_DIR/$ITEM" ]; then
      rsync -av --delete "$NEXTCLOUD_DIR/$ITEM" "$BRAVE_DIR/"
      echo "✅ Restored: $ITEM"
    else
      echo "⚠️ Skipped (not found in backup): $ITEM"
    fi
  done

  echo "🎉 Restore completed."

  if [ "$BRAVE_WAS_RUNNING" -eq 1 ]; then
    reopen_brave
  fi
}
