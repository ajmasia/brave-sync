#!/bin/bash

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
    echo "Brave Sync is not installed or version unknown."
  fi
  ;;
*)
  echo "Usage: brave-sync [backup|restore|install|update|uninstall|version]"
  ;;
esac
