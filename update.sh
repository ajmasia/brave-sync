#!/bin/bash

INSTALL_DIR="$HOME/.local/share/brave-sync"

echo "🔄 Updating Brave Sync..."

# Check if installed
if [ ! -d "$INSTALL_DIR" ]; then
  echo "❌ Brave Sync is not installed. Run install.sh first."
  exit 1
fi

# Check if Git repo
if [ ! -d "$INSTALL_DIR/.git" ]; then
  echo "⚠️  Cannot update: Brave Sync was not installed from Git."
  echo "ℹ️  Reinstall using the Git version if you want update support:"
  echo "   curl -sL https://raw.githubusercontent.com/YOUR-USERNAME/brave-sync/main/install.sh | bash"
  exit 1
fi

# Pull latest changes
echo "⬇️  Fetching latest version from GitHub..."
git -C "$INSTALL_DIR" pull --quiet

# Re-run installer
echo "🔧 Re-applying installation..."
bash "$INSTALL_DIR/install.sh"

# Show updated version
if [ -f "$INSTALL_DIR/.version" ]; then
  echo "✅ Updated to Brave Sync version $(cat "$INSTALL_DIR/.version")"
else
  echo "✅ Update complete (version unknown)"
fi
