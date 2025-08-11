#!/usr/bin/env bash

# Core paths (all derived from REPO_ROOT where applicable)
BIN_DIR="$HOME/.local/bin"
BRAVE_DIR="$HOME/.config/BraveSoftware/Brave-Browser/Default"
CONFIG_DIR="$HOME/.config/brave-sync"
CONFIG_FILE="$CONFIG_DIR/config"
DEFAULT_SYNC_PATH="$HOME/Nextcloud/data/brave-sync"
DESKTOP_DIR="$HOME/.local/share/applications"
INSTALL_DIR="$HOME/.local/share/brave-sync"

# Version info
VERSION_FILE_LOCAL="$ROOT_DIR/.version"
REPO_VERSION_FILE="$ROOT_DIR/version"

declare -a DATA_TO_SYNC=(Bookmarks Extensions "Web Data" Preferences History "Sync Data")
