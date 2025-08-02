#!/usr/bin/env bash

VERSION_FILE="$HOME/.local/share/brave-sync/.version"

if [ -f "$VERSION_FILE" ]; then
  echo "Brave Sync version: $(cat "$VERSION_FILE")"
else
  echo "Brave Sync version: unknown"
fi
