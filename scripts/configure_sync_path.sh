#!/bin/bash

CONFIG_DIR="$HOME/.config/brave-sync"
CONFIG_FILE="$CONFIG_DIR/config"
DEFAULT_SYNC_PATH="$HOME/Nextcloud/data/brave-sync"

mkdir -p "$CONFIG_DIR"

read -rp "📂 Enter the full path to your Brave sync folder [$DEFAULT_SYNC_PATH]: " SYNC_PATH
SYNC_PATH="${SYNC_PATH:-$DEFAULT_SYNC_PATH}"
EXPANDED_PATH=$(eval echo "$SYNC_PATH")

if [[ -z "$EXPANDED_PATH" ]]; then
  echo "❌ Path cannot be empty. Aborted."
  exit 1
elif [[ "$EXPANDED_PATH" != /* ]]; then
  echo "❌ Path must be absolute (start with '/'). Aborted."
  exit 1
elif [ ! -d "$EXPANDED_PATH" ]; then
  echo "❌ Directory does not exist: $EXPANDED_PATH. Aborted."
  exit 1
else
  echo "SYNC_DIR=\"$EXPANDED_PATH\"" >"$CONFIG_FILE"
  echo "✅ Sync directory saved to $CONFIG_FILE"
fi
