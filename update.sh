#!/bin/bash

source "$(dirname "$0")/env.sh"

echo "🔄 Checking for Brave Sync updates..."

# Check if installed
if [ ! -d "$INSTALL_DIR" ]; then
  echo "❌ Brave Sync is not installed. Run install.sh first."
  exit 1
fi

# Check if Git repo
if [ ! -d "$INSTALL_DIR/.git" ]; then
  echo "⚠️  Cannot auto-update: not a Git installation."
  echo "ℹ️  Reinstall using Git:"
  echo "   curl -sL https://raw.githubusercontent.com/ajamsia/brave-sync/main/install.sh | bash"
  exit 1
fi

# Fetch latest changes without applying
git -C "$INSTALL_DIR" fetch --quiet

# Get local version
if [ -s "$VERSION_FILE_LOCAL" ]; then
  LOCAL_VERSION=$(cat "$VERSION_FILE_LOCAL")
else
  LOCAL_VERSION="unknown"
fi

# Get remote version from GitHub (lowercase file)
if git -C "$INSTALL_DIR" show origin/main:version >/dev/null 2>&1; then
  REMOTE_VERSION=$(git -C "$INSTALL_DIR" show origin/main:version)
else
  REMOTE_VERSION="unknown"
fi

# Compare versions
if [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
  echo "✅ Brave Sync is already up to date (version $LOCAL_VERSION)"
  exit 0
fi

echo "⬇️  Updating from $LOCAL_VERSION → $REMOTE_VERSION..."
git -C "$INSTALL_DIR" pull --quiet

# Re-run installer
bash "$INSTALL_DIR/install.sh"

# Update version file
cp "$REPO_VERSION_FILE" "$VERSION_FILE_LOCAL"
echo "✅ Updated to Brave Sync version $REMOTE_VERSION"
