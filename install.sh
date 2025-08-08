#!/usr/bin/env bash

BIN_DIR="$HOME/.local/bin"
INSTALL_DIR="$HOME/.local/share/brave-sync"
REPO_URL="https://github.com/ajmasia/brave-sync.git"

ICON_SOURCE="$INSTALL_DIR/icons/brave-sync.png"
ICON_TARGET_DIR="$HOME/.local/share/icons/hicolor/48x48/apps"
ICON_TARGET="$ICON_TARGET_DIR/brave-sync.png"

CONFIG_DIR="$HOME/.config/brave-sync"
CONFIG_FILE="$CONFIG_DIR/config"

BRANCH="${BRANCH:-main}"

DEFAULT_SYNC_PATH="$HOME/Nextcloud/data/brave-sync"
DESKTOP_DIR="$HOME/.local/share/applications"

echo "📦 Installing Brave Sync..."

# Clone or update repo
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "🔄 Updating existing installation..."
  git -C "$INSTALL_DIR" pull --quiet
else
  echo "⬇️ Cloning repository ..."
  git clone --quiet --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

# Ask user for sync destination
mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ]; then
  echo "📂 Existing sync directory found in config:"
  grep SYNC_DIR "$CONFIG_FILE"
else
  read -rp "📂 Enter the full path to your Brave sync folder [$DEFAULT_SYNC_PATH]: " SYNC_PATH
  SYNC_PATH="${SYNC_PATH:-$DEFAULT_SYNC_PATH}"
  EXPANDED_PATH=$(eval echo "$SYNC_PATH")

  if [[ -z "$EXPANDED_PATH" ]]; then
    echo "❌ Path cannot be empty. Install aborted."
    exit 1
  elif [[ "$EXPANDED_PATH" != /* ]]; then
    echo "❌ Path must be absolute (start with '/'). Install aborted."
    exit 1
  elif [ ! -d "$EXPANDED_PATH" ]; then
    echo "❌ Directory does not exist: $EXPANDED_PATH. Install aborted."
    exit 1
  else
    echo "SYNC_DIR=\"$EXPANDED_PATH\"" >"$CONFIG_FILE"
    echo "✅ Sync directory saved to $CONFIG_FILE"
  fi
fi

# Create launcher scripts
echo '#!/bin/bash
bash "$HOME/.local/share/brave-sync/scripts/sync.sh" backup' >"$BIN_DIR/brave-backup"

echo '#!/bin/bash
bash "$HOME/.local/share/brave-sync/scripts/sync.sh" restore' >"$BIN_DIR/brave-restore"

chmod +x "$BIN_DIR/brave-backup" "$BIN_DIR/brave-restore"

# Install icons
mkdir -p "$ICON_TARGET_DIR"
cp "$ICON_SOURCE" "$ICON_TARGET"

# Update icon cache if available
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1
fi

# Install .desktop launchers
mkdir -p "$DESKTOP_DIR"
cp "$INSTALL_DIR/desktop/"*.desktop "$DESKTOP_DIR/"

# Install main CLI command
cp "$INSTALL_DIR/cli/brave_sync.sh" "$BIN_DIR/brave-sync"
chmod +x "$BIN_DIR/brave-sync"

# Save version info
cp "$INSTALL_DIR/version" "$INSTALL_DIR/.version"

echo "📦 Installed Brave Sync version $(cat "$INSTALL_DIR/.version")"
echo "➡️  Run 'brave-sync help' to see available commands"
