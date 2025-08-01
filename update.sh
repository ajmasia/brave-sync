#!/bin/bash

INSTALL_DIR="$HOME/.local/share/brave-sync"
VERSION_FILE_LOCAL="$INSTALL_DIR/.version"
VERSION_FILE_REPO="$INSTALL_DIR/VERSION"

echo "🔄 Checking for Brave Sync updates..."

# Check installation
if [ ! -d "$INSTALL_DIR" ]; then
  echo "❌ Brave Sync is not installed. Run install.sh first."
  exit 1
fi

# Check Git repo
if [ ! -d "$INSTALL_DIR/.git" ]; then
  echo "⚠️  Cannot auto-update: not a Git installation."
  echo "ℹ️  Reinstall using Git:"
  echo "   curl -sL https://raw.githubusercontent.com/YOUR-USERNAME/brave-sync/main/install.sh | bash"
  exit 1
fi

# Pull latest changes from remote
git -C "$INSTALL_DIR" fetch --quiet

# Get local version
LOCAL_VERSION="none"
[ -f "$VERSION_FILE_LOCAL" ] && LOCAL_VERSION=$(cat "$VERSION_FILE_LOCAL")

# Get remote version (without checkout)
REMOTE_VERSION=$(git -C "$INSTALL_DIR" show origin/main:VERSION 2>/dev/null)

# Compare
if [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
  echo "✅ Brave Sync is already up to date (version $LOCAL_VERSION)"
  exit 0
fi

echo "⬇️  Updating from $LOCAL_VERSION → $REMOTE_VERSION"
git -C "$INSTALL_DIR" pull --quiet

# Re-run installer
bash "$INSTALL_DIR/install.sh"

# Confirm update
echo "$REMOTE_VERSION" >"$VERSION_FILE_LOCAL"
echo "✅ Updated to Brave Sync version $REMOTE_VERSION"
