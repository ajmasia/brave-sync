#!/bin/bash

print_help() {
  echo "📦 Brave Sync CLI"
  echo ""
  echo "Usage: brave-sync <command>"
  echo ""
  echo "Commands:"
  echo "  backup       Backup Brave data to Nextcloud"
  echo "  restore      Restore Brave data from Nextcloud"
  echo "  update       Update Brave Sync (from Git)"
  echo "  uninstall    Remove Brave Sync"
  echo "  version      Show installed version"
  echo "  help         Show this help message"
  echo ""
  echo "Examples:"
  echo "  brave-sync backup"
  echo "  brave-sync update"
}

case "$1" in
backup) brave-backup ;;
restore) brave-restore ;;
update) bash "$HOME/.local/share/brave-sync/update.sh" ;;
uninstall) bash "$HOME/.local/share/brave-sync/uninstall.sh" ;;
version)
  if [ -f "$HOME/.local/share/brave-sync/.version" ]; then
    echo "Brave Sync version: $(cat "$HOME/.local/share/brave-sync/.version")"
  else
    echo "Brave Sync version: unknown"
  fi
  ;;
config)
  bash "$HOME/.local/share/brave-sync/scripts/configure_sync_path.sh"
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
