#!/usr/bin/env bash

# Fallback to install path if not in DEV_MODE
if [ "${DEV_MODE:-false}" = true ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  ROOT_DIR="$HOME/.local/share/brave-sync"
fi

source "$ROOT_DIR/bootstrap.sh"

include_script "scripts/env.sh"

echo "⚠️  This will uninstall Brave Sync for the current user."
read -rp "Are you sure? [y/N] " confirm
case "$confirm" in
[yY][eE][sS] | [yY]) ;;
*)
  echo "❌ Uninstall cancelled."
  exit 0
  ;;
esac

# Remove desktop launchers
echo "🗑️ Removing .desktop launchers..."
rm -f "$DESKTOP_DIR/brave-backup.desktop"
rm -f "$DESKTOP_DIR/brave-restore.desktop"

# Remove launchable commands
echo "🗑️ Removing executable wrappers..."
rm -f "$BIN_DIR/brave-backup"
rm -f "$BIN_DIR/brave-restore"
rm -f "$BIN_DIR/brave-sync"

# Remove installed folder
echo "🗑️ Removing installation directory..."
rm -rf "$INSTALL_DIR"

# Remove installed folder
echo "🗑️ Removing config directory..."
rm -rf "$CONFIG_DIR"

echo "✅ Brave Sync has been removed."
