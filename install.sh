#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# brave-sync installer (works from GitHub via curl | bash OR from local repo)
# - Prefers 'uv tool install' (isolated user tool). Fallback to 'pipx install'.
# - If running inside a local repo (pyproject.toml present), installs from '.'.
# - If not, installs directly from GitHub (branch/tag via --ref, default 'main').
# - Preflight checks for runtime deps: rsync (and procps on Linux).
#
# Options:
#   --ref <branch|tag>   Git ref when installing from GitHub (default: main)
#   --force              Reinstall/overwrite (tool mode)
#   --editable           Dev install into .venv with 'uv pip install -e .'
#   --check              Only run dependency checks and exit
# -----------------------------------------------------------------------------

REPO="ajmasia/brave-sync"
REF="main"
FORCE_FLAG=""
EDITABLE=0
CHECK_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
  --ref)
    REF="${2:-main}"
    shift 2
    ;;
  --force)
    FORCE_FLAG="--force"
    shift
    ;;
  --editable)
    EDITABLE=1
    shift
    ;;
  --check)
    CHECK_ONLY=1
    shift
    ;;
  -h | --help)
    cat <<EOF
Usage: $(basename "$0") [--ref <branch|tag>] [--force] [--editable] [--check]
EOF
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    exit 2
    ;;
  esac
done

has_cmd() { command -v "$1" >/dev/null 2>&1; }

# ---------- OS detect & hints ----------
OS_FAMILY="other"
PKG_HINT() { :; }

detect_os() {
  case "$(uname -s)" in
  Linux) OS_FAMILY="linux" ;;
  Darwin) OS_FAMILY="mac" ;;
  *) OS_FAMILY="other" ;;
  esac
  if [[ "$OS_FAMILY" == "linux" ]]; then
    if has_cmd apt; then
      PKG_HINT() { case "$1" in
        rsync) echo "sudo apt update && sudo apt install -y rsync" ;;
        procps) echo "sudo apt update && sudo apt install -y procps" ;;
        uv) echo "curl -LsSf https://astral.sh/uv/install.sh | sh" ;;
        pipx) echo "sudo apt install -y pipx && pipx ensurepath" ;;
        esac }
    elif has_cmd dnf; then
      PKG_HINT() { case "$1" in
        rsync) echo "sudo dnf install -y rsync" ;;
        procps) echo "sudo dnf install -y procps-ng" ;;
        uv) echo "curl -LsSf https://astral.sh/uv/install.sh | sh" ;;
        pipx) echo "python3 -m pip install --user pipx && pipx ensurepath" ;;
        esac }
    elif has_cmd pacman; then
      PKG_HINT() { case "$1" in
        rsync) echo "sudo pacman -S --needed rsync" ;;
        procps) echo "sudo pacman -S --needed procps-ng" ;;
        uv) echo "curl -LsSf https://astral.sh/uv/install.sh | sh" ;;
        pipx) echo "python3 -m pip install --user pipx && pipx ensurepath" ;;
        esac }
    else
      PKG_HINT() { case "$1" in
        rsync) echo "Install rsync with your package manager" ;;
        procps) echo "Install procps/procps-ng with your package manager" ;;
        uv) echo "Install uv: https://docs.astral.sh/uv/" ;;
        pipx) echo "Install pipx: https://pypa.github.io/pipx/" ;;
        esac }
    fi
  elif [[ "$OS_FAMILY" == "mac" ]]; then
    PKG_HINT() { case "$1" in
      rsync) echo "brew install rsync" ;;
      uv) echo "curl -LsSf https://astral.sh/uv/install.sh | sh" ;;
      pipx) echo "python3 -m pip install --user pipx && pipx ensurepath" ;;
      procps) echo "(not required on macOS)" ;;
      esac }
  else
    PKG_HINT() { case "$1" in
      rsync) echo "Install rsync for your OS" ;;
      uv) echo "Install uv: https://docs.astral.sh/uv/" ;;
      pipx) echo "Install pipx: https://pypa.github.io/pipx/" ;;
      procps) echo "Install procps for your OS" ;;
      esac }
  fi
}

require() {
  # $1=cmd $2=label $3=hint-key
  if ! has_cmd "$1"; then
    echo "❌ Missing dependency: $2 ('$1')"
    local hint
    hint="$(PKG_HINT "$3")"
    [[ -n "$hint" ]] && echo "   → $hint"
    return 1
  fi
  return 0
}

require_python39_if_pipx() {
  if has_cmd uv; then return 0; fi
  if ! has_cmd python3; then
    echo "❌ Missing dependency: Python 3.9+ ('python3')"
    return 1
  fi
  python3 - <<'PY' >/dev/null || {
import sys; raise SystemExit(0 if sys.version_info >= (3,9) else 1)
PY
    echo "❌ Python >= 3.9 is required"
    return 1
  }
}

preflight() {
  detect_os
  local ok=1
  require rsync "rsync" rsync || ok=0
  if [[ "$OS_FAMILY" == "linux" ]]; then
    (has_cmd pgrep && has_cmd pkill) || {
      echo "❌ Missing: pgrep/pkill (procps)"
      echo "   → $(PKG_HINT procps)"
      ok=0
    }
  fi
  if has_cmd uv; then :; else
    require pipx "pipx" pipx || ok=0
    require_python39_if_pipx || ok=0
  fi
  if [[ "$ok" -ne 1 ]]; then
    echo
    echo "Fix the missing dependencies above and re-run."
    exit 127
  fi
  echo "✅ Dependencies OK."
}

ensure_path_hint() {
  case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *)
    echo "ℹ️  Add ~/.local/bin to PATH if 'brave-sync' is not found:"
    echo "    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc && source ~/.bashrc"
    ;;
  esac
}

install_local() {
  # Running inside a repo (pyproject.toml present)
  if [[ "$EDITABLE" -eq 1 ]]; then
    if ! has_cmd uv; then
      echo "❌ Editable mode requires 'uv'"
      echo "   → $(PKG_HINT uv)"
      exit 127
    fi
    echo "→ Creating .venv and installing in editable mode…"
    uv venv
    # shellcheck disable=SC1091
    source .venv/bin/activate
    uv pip install -e .
    echo "✅ Editable install done. Activate with: source .venv/bin/activate"
  else
    if has_cmd uv; then
      echo "→ Installing as user tool via uv (from local repo)…"
      uv tool install ${FORCE_FLAG} --from . brave-sync
    else
      echo "→ 'uv' not found; installing via pipx (from local repo)…"
      pipx install .
    fi
  fi
}

install_remote() {
  # No repo around → install from GitHub
  if has_cmd uv; then
    echo "→ Installing via uv tool from git (ref: $REF)…"
    uv tool install ${FORCE_FLAG} --from "git+https://github.com/${REPO}@${REF}" brave-sync
  else
    echo "→ Installing via pipx from git (ref: $REF)…"
    pipx install "git+https://github.com/${REPO}@${REF}"
  fi
}

postcheck() {
  echo "— Verifying installation —"
  if command -v brave-sync >/dev/null 2>&1; then
    brave-sync version || true
    echo "✅ Installed. Try: brave-sync --help"
  else
    echo "⚠️  'brave-sync' is not on PATH yet."
    ensure_path_hint
  fi
}

# ---------------- main ----------------
preflight
[[ "$CHECK_ONLY" -eq 1 ]] && exit 0

if [[ -f "pyproject.toml" ]]; then
  install_local
else
  install_remote
fi

postcheck
