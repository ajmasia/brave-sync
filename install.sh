#!/bin/bash

REPO_URL="https://github.com/ajmasia/brave-sync.git"
INSTALL_DIR="$HOME/.local/share/brave-sync"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

echo "📦 Installing Brave Sync..."

# Clone or update repo
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "🔄 Updating existing installation..."
  git -C "$INSTALL_DIR" pull --quiet
else
  echo "⬇️ Cloning repository..."
  git clone --quiet "$REPO_URL" "$INSTALL_DIR"
fi

# Create bin directory
mkdir -p "$BIN_DIR"

# Create launcher scripts
echo '#!/bin/bash
source "$HOME/.local/share/brave-sync/scripts/functions.sh"
bash "$HOME/.local/share/brave-sync/scripts/backup_brave.sh"' >"$BIN_DIR/brave-backup"

echo '#!/bin/bash
source "$HOME/.local/share/brave-sync/scripts/functions.sh"
bash "$HOME/.local/share/brave-sync/scripts/restore_brave.sh"' >"$BIN_DIR/brave-restore"

chmod +x "$BIN_DIR/brave-backup" "$BIN_DIR/brave-restore"

# Install .desktop launchers
mkdir -p "$DESKTOP_DIR"
cp "$INSTALL_DIR/desktop/"*.desktop "$DESKTOP_DIR/"

# version
# Save version info
cp "$INSTALL_DIR/VERSION" "$INSTALL_DIR/.version"
echo "📦 Installed Brave Sync version $(cat "$INSTALL_DIR/.version")"
echo "➡️  You can run: brave-backup or brave-restore"
