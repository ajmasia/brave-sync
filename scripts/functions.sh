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
