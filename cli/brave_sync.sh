#!/bin/bash

source "$(dirname "$0")/../env.sh"

print_help() {
  echo "📦 Brave Sync CLI"
  echo ""
  echo "Usage: brave-sync <command>"
  echo ""
  echo "Commands:"
  echo "  backup     - Backup Brave data to sync folder"
  echo "  restore    - Restore Brave data from sync folder"
  echo "  update     - Update Brave Sync from GitHub"
  echo "  config     - Edit config"
  echo "  uninstall  - Uninstall Brave Sync"
  echo "  version    - Show installed version"
  echo "  help       - Show this help message"
  echo ""
  echo "Examples:"
  echo "  brave-sync backup"
  echo "  brave-sync config"
}

case "$1" in
backup)
  bash "$HOME/.local/share/brave-sync/scripts/sync.sh" backup
  ;;
restore)
  bash "$HOME/.local/share/brave-sync/scripts/sync.sh" restore
  ;;
config)
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found: $CONFIG_FILE"
    echo "💡 Run 'brave-sync install' to set it up."
    exit 1
  fi

  ${EDITOR:-nano} "$CONFIG_FILE"
  ;;
update)
  bash "$HOME/.local/share/brave-sync/update.sh"
  ;;
uninstall)
  bash "$HOME/.local/share/brave-sync/uninstall.sh"
  ;;
version)
  VERSION_FILE="$HOME/.local/share/brave-sync/.version"
  if [ -f "$VERSION_FILE" ]; then
    echo "Brave Sync version: $(cat "$VERSION_FILE")"
  else
    echo "Brave Sync version: unknown"
  fi
  ;;
help | -h | --help | "")
  print_help
  ;;
*)
  echo "❌ Unknown command: $1"
  echo "Run 'brave-sync help' to see available commands."
  exit 1
  ;;
esac
