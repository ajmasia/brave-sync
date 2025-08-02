#!/usr/bin/env bash

function print_help() {
  cat <<-EOF
📦 Brave Sync CLI help

Usage: brave-sync <command>

Commands:
  backup     Backup Brave data to your sync folder
  restore    Restore Brave data
  config     Edit configuration file (defines sync path)
  update     Pull latest from GitHub and reinstall
  uninstall  Remove Brave Sync from your system
  version    Show installed Brave‑Sync version
  help       Show this message

Examples:
  brave-sync backup
  brave-sync config
EOF
}
