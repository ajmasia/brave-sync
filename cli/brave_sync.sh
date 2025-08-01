#!/bin/bash

print_help() {
  echo "📦 Brave Sync CLI"
  echo ""
  echo "Usage: brave-sync <command>"
  echo ""
  echo "Commands:"
  echo "  backup       Backup Brave data to Nextcloud"
  echo "  restore      Restore Brave data from Nextcloud"
  echo "  install      Install or reinstall Brave Sync"
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
install) bash "$HOME/.local/share/brave-sync/install.sh" ;;
update) bash "$HOME/.local/share/brave-sync/update.sh" ;;
uninstall) bash "$HOME/.local/share/brave-sync/uninstall.sh" ;;
version)
  if [ -f "$HOME/.local/share/brave-sync/.version" ]; then
    echo "Brave Sync version: $(cat "$HOME/.local/share/brave-sync/.version")"
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
