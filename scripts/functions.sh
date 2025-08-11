#!/bin/bash

run_backup() {
  if check_is_close_brave_is_needed; then
    BRAVE_WAS_CLOSED=1
  else
    BRAVE_WAS_CLOSED=0
  fi

  for ITEM in Bookmarks Extensions "Web Data" Preferences History "Sync Data"; do
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
}

run_restore() {
  if check_is_close_brave_is_needed; then
    BRAVE_WAS_CLOSED=1
  else
    BRAVE_WAS_CLOSED=0
  fi

  for ITEM in Bookmarks Extensions "Web Data" Preferences History "Sync Data"; do
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
}
