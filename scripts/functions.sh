#!/bin/bash

# Sets the correct Brave command based on what's installed
set_brave_command() {
  if command -v brave-browser >/dev/null 2>&1; then
    BRAVE_CMD="brave-browser"
  elif command -v brave >/dev/null 2>&1; then
    BRAVE_CMD="brave"
  else
    echo "❌ Brave is not installed or not found in PATH."
    exit 1
  fi
}

# Returns true if Brave is running (either variant)
is_brave_running() {
  pgrep -x brave-browser >/dev/null 2>&1 || pgrep -x brave >/dev/null 2>&1
}

# Kills all Brave processes safely
close_brave() {
  echo "🔻 Closing Brave..."
  pgrep -x brave-browser >/dev/null && pkill -x brave-browser
  pgrep -x brave >/dev/null && pkill -x brave
  sleep 2
  echo "✅ Brave has been closed."
}
