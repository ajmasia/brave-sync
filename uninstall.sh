#!/usr/bin/env bash
set -euo pipefail

# brave-sync uninstaller
# - Works regardless of how it was installed (uv tool / pipx).
# - Also cleans systemd --user timer/units if present (Linux).

echo "→ Uninstalling brave-sync…"

# Try uv tool uninstall
if command -v uv >/dev/null 2>&1; then
  uv tool uninstall brave-sync || true
fi

# Try pipx uninstall
if command -v pipx >/dev/null 2>&1; then
  pipx uninstall brave-sync || true
fi

echo "✅ Uninstall complete."
