#!/bin/bash

# Load Brave utility functions
source "$(dirname "$0")/functions.sh"

# Set the Brave command (brave or brave-browser)
set_brave_command

# Paths
BRAVE_DIR="$HOME/.config/BraveSoftware/Brave-Browser/Default"
NEXTCLOUD_DIR="$HOME/Nextcloud/data/brave-sync"

echo "Using Brave command: $BRAVE_CMD"

# Check if Brave is running
if is_brave_running; then
  read -rp "⚠️ Brave is currently running. Do you want to close it to proceed with the backup? [y/N] " response
  case "$response" in
  [yY][eE][sS] | [yY])
    close_brave
    ;;
  *)
    echo "❌ Backup cancelled. Brave must be closed to continue."
    exit 1
    ;;
  esac
fi

# Ensure destination exists
mkdir -p "$NEXTCLOUD_DIR"

# Files/folders to sync
FILES=(
  "Bookmarks"
  "Extensions"
  "Web Data"
  "Preferences"
  "History"
)

# Backup each item
for ITEM in "${FILES[@]}"; do
  if [ -e "$BRAVE_DIR/$ITEM" ]; then
    rsync -av --delete "$BRAVE_DIR/$ITEM" "$NEXTCLOUD_DIR/"
    echo "✅ Backed up: $ITEM"
  else
    echo "⚠️ Skipped (not found): $ITEM"
  fi
done

echo "🎉 Backup completed to $NEXTCLOUD_DIR"

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
