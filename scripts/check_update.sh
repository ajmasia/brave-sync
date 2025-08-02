#!/usr/bin/env bash

LOCAL_VERSION_FILE="$ROOT_DIR/.version"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/ajmasia/brave-sync/main/version"

# Skip if local version is missing
if [ ! -f "$LOCAL_VERSION_FILE" ]; then
  return 0
fi

LOCAL_VERSION=$(cat "$LOCAL_VERSION_FILE")
REMOTE_VERSION=$(curl -fsSL "$REMOTE_VERSION_URL" 2>/dev/null)

# Only notify if versions differ and remote is available
if [[ -n "$REMOTE_VERSION" && "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then
  echo "🔔 Update available: $REMOTE_VERSION (installed: $LOCAL_VERSION)"
  echo -e "   Run: brave-sync update\n"
fi
