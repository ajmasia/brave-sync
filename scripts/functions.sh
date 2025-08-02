#!/bin/bash

run_backup() {
  echo -e "Starting Brave Sync backup...\n"
  if check_is_close_brave_is_needed; then
    BRAVE_WAS_CLOSED=1
  else
    BRAVE_WAS_CLOSED=0
  fi

  for ITEM in Bookmarks Extensions "Web Data" Preferences History; do
    if [ -e "$BRAVE_DIR/$ITEM" ]; then
      rsync -av --delete "$BRAVE_DIR/$ITEM" "$CLOUD_DIR/"
      echo "✅ Backed up: $ITEM"
    else
      echo "⚠️ Skipped (not found): $ITEM"
    fi
  done

  echo "🎉 Backup completed."

  if [ "$BRAVE_WAS_CLOSED" -eq 1 ]; then
    reopen_brave
  fi
  command -v notify-send >/dev/null && notify-send "Brave Sync" "Backup completed successfully."
}

run_restore() {
  echo -e "Starting Brave Sync restore...\n"
  if check_is_close_brave_is_needed; then
    BRAVE_WAS_CLOSED=1
  else
    BRAVE_WAS_CLOSED=0
  fi

  for ITEM in Bookmarks Extensions "Web Data" Preferences History; do
    if [ -e "$CLOUD_DIR/$ITEM" ]; then
      rsync -av --delete "$CLOUD_DIR/$ITEM" "$BRAVE_DIR/"
      echo "✅ Restored: $ITEM"
    else
      echo "⚠️ Skipped (not found in backup): $ITEM"
    fi
  done

  echo "🎉 Restore completed."

  if [ "$BRAVE_WAS_CLOSED" -eq 1 ]; then
    reopen_brave
  fi
  command -v notify-send >/dev/null && notify-send "Brave Sync" "Restore completed successfully."
}
