#!/bin/bash

# Load Brave utility functions
source "$(dirname "$0")/functions.sh"

# Set the Brave command (brave or brave-browser)
set_brave_command

# Paths
BRAVE_DIR="$HOME/.config/BraveSoftware/Brave-Browser/Default"
NEXTCLOUD_DIR="$HOME/Nextcloud/data/brave-sync"

# Check if Brave is running
if is_brave_running; then
  read -rp "⚠️ Brave is currently running. Do you want to close it to proceed with the restore? [y/N] " response
  case "$response" in
  [yY][eE][sS] | [yY])
    close_brave
    ;;
  *)
    echo "❌ Restore cancelled. Brave must be closed to continue."
    exit 1
    ;;
  esac
fi

# Files/folders to restore
FILES=(
  "Bookmarks"
  "Extensions"
  "Web Data"
  "Preferences"
  "History"
)

# Restore each item
for ITEM in "${FILES[@]}"; do
  if [ -e "$NEXTCLOUD_DIR/$ITEM" ]; then
    rsync -av --delete "$NEXTCLOUD_DIR/$ITEM" "$BRAVE_DIR/"
    echo "✅ Restored: $ITEM"
  else
    echo "⚠️ Skipped (not found in backup): $ITEM"
  fi
done

echo "🎉 Restore completed to $BRAVE_DIR"

# Ask to reopen Brave
read -rp "🔁 Do you want to reopen Brave and restore your previous session? [y/N] " reopen
case "$reopen" in
[yY][eE][sS] | [yY])
  echo "🚀 Launching Brave..."
  nohup "$BRAVE_CMD" --restore-last-session >/dev/null 2>&1 &
  ;;
*)
  echo "👍 Brave was not restarted."
  ;;
esac
