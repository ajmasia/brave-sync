#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

source "$REPO_ROOT/env.sh"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  echo "💡 Run 'brave-sync install' to set it up."
  exit 1
fi

${EDITOR:-nano} "$CONFIG_FILE"
