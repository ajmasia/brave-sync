#!/usr/bin/env bash

include_script() {
  local rel_path="$1"
  local full_path="$ROOT_DIR/$rel_path"

  if [ -f "$full_path" ]; then
    source "$full_path"
  else
    echo "❌ Script not found: $full_path"
    exit 1
  fi
}
