#!/usr/bin/env bash

# Fallback to install path if not in DEV_MODE
if [ "${DEV_MODE:-false}" = true ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  ROOT_DIR="$HOME/.local/share/brave-sync"
fi

source "$ROOT_DIR/bootstrap.sh"

include_script "scripts/env.sh"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  echo "💡 Run 'brave-sync install' to set it up."
  exit 1
fi

${EDITOR:-nano} "$CONFIG_FILE"
