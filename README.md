# brave-sync (Python + Typer + rsync)

A small CLI to **backup and restore** your **Brave Browser** profile locally using **rsync**.  
It includes interactive configuration, dry-run verification, and (optional) daily backups via **systemd** (user).

---

## Features

- **Commands**: `config`, `backup`, `restore`, `verify`, `version` (optional: `schedule` on Linux).
- **Fast & safe** backups with **rsync**; preview with `--dry-run`.
- **Mixed items** (files & directories) handled correctly.
- **Graceful Brave shutdown** before copying (avoids corruption).
- **Per-user config** with sensible OS defaults.
- **Easy installation**: `uv`/`pipx` or one-liner via `curl` (from GitHub).
- **Single source of truth** for version in `pyproject.toml`.

---

## What gets backed up (by default)

These items are copied from your Brave profile:

- `Bookmarks` *(file)*
- `Preferences` *(file)*
- `History` *(file)*
- `Extensions` *(directory)*
- `Sync Data` *(directory)*

> You can tweak the list in code (`DEFAULT_ITEMS` in `backup_cmd.py` / `restore_cmd.py`).

---

## Requirements

- **rsync** (mandatory)
  - Debian/Ubuntu: `sudo apt install rsync`
  - Fedora: `sudo dnf install rsync`
  - Arch: `sudo pacman -S rsync`
  - macOS: `brew install rsync`
- **Linux**: also **pgrep/pkill** (package `procps` / `procps-ng`)
  - Debian/Ubuntu: `sudo apt install procps`
  - Fedora: `sudo dnf install procps-ng`
  - Arch: `sudo pacman -S procps-ng`
- For installing as a user tool:
  - **Recommended**: [uv](https://docs.astral.sh/uv/)
  - **Alternative**: [pipx](https://pypa.github.io/pipx/) + **Python ≥ 3.9**

> If the `brave-sync` command isn’t found after install, add `~/.local/bin` to your `PATH`:
>
> ```bash
> echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
> ```

---

## Installation

### Option 1 — One-liner via `curl` (install from GitHub)

Install from **main**:

```bash
curl -fsSL https://raw.githubusercontent.com/ajmasia/brave-sync/main/install.sh | bash
```

Install from a **specific branch or tag**:

```bash
curl -fsSL https://raw.githubusercontent.com/ajmasia/brave-sync/main/install.sh | bash -s -- --ref <branch_or_tag>
# example:
# curl -fsSL https://raw.githubusercontent.com/ajmasia/brave-sync/main/install.sh | bash -s -- --ref feat/migrate-to-python-typer-uv
```

Force re-install:

```bash
curl -fsSL https://raw.githubusercontent.com/ajmasia/brave-sync/main/install.sh | bash -s -- --force
```

Dependency check only:

```bash
curl -fsSL https://raw.githubusercontent.com/ajmasia/brave-sync/main/install.sh | bash -s -- --check
```

---

### Option 2 — Install directly from Git with `uv` or `pipx`

Using **uv** (recommended):

```bash
# main
uv tool install --from git+https://github.com/ajmasia/brave-sync@main brave-sync

# specific branch/tag
uv tool install --force --from git+https://github.com/ajmasia/brave-sync@<branch_or_tag> brave-sync
```

Using **pipx**:

```bash
pipx install "git+https://github.com/ajmasia/brave-sync@main"
```

---

### Option 3 — From a local repository

```bash
git clone https://github.com/ajmasia/brave-sync
cd brave-sync

# standard user-tool install (prefers uv, falls back to pipx)
bash install.sh

# dev install (editable into .venv)
bash install.sh --editable
```

---

## Uninstallation

One-liner from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/ajmasia/brave-sync/main/uninstall.sh | bash
```

From a local repo:

```bash
bash uninstall.sh
```

Manual (just in case):

```bash
(uv tool uninstall brave-sync 2>/dev/null || true)
(pipx uninstall brave-sync 2>/dev/null || true)

# If you enabled the timer (Linux)
systemctl --user disable --now brave-sync.timer 2>/dev/null || true
rm -f ~/.config/systemd/user/brave-sync.{service,timer}
systemctl --user daemon-reload 2>/dev/null || true
```

---

## Usage

General help:

```bash
brave-sync --help
```

### 1) Configure

Create/update your config (profile path, sync dir, behavior):

```bash
brave-sync config
```

**Where config is saved** (via `platformdirs`):

- Linux: `~/.config/brave-sync/config.json`
- macOS: `~/Library/Application Support/brave-sync/config.json`
- Windows: `%APPDATA%\brave-sync\config.json`

### 2) Backup

Preview (no writes):

```bash
brave-sync backup --dry-run
```

Run:

```bash
brave-sync backup
```

> Default is **no `--delete`** in the destination (safer). Brave is closed before copying.

### 3) Restore

Preview:

```bash
brave-sync restore --dry-run
```

Run (asks for confirmation):

```bash
brave-sync restore
```

### 4) Verify

Show what **would change** for both directions (no writes):

```bash
brave-sync verify
```

### 5) Version

```bash
brave-sync version
```

### 6) (Optional) Schedule daily backups (Linux)

Manage a **systemd user timer**:

```bash
brave-sync schedule enable
brave-sync schedule status
brave-sync schedule run-now
brave-sync schedule disable
```

> Requires `systemd --user`. Creates `~/.config/systemd/user/brave-sync.{service,timer}` with `OnCalendar=daily`.

---

## rsync semantics (important)

- The CLI mirrors the classic Bash style:
  - **File**: `rsync SRC  DST_DIR/` ⇒ copied as `DST_DIR/<name>`
  - **Directory**: `rsync SRC  DST_DIR/` *(no trailing slash on `SRC`)* ⇒ `DST_DIR/<dirname>/`
- We **don’t** use `--delete` by default. If you want a strict mirror for directories, enable it in code (set `delete=True` for dir cases).

---

## Development

Project layout:

```
brave-sync
├─ pyproject.toml
├─ install.sh 
├─ uninstall.sh
├─ src/brave_sync
│  ├─ cli.py
│  ├─ __main__.py
│  ├─ core
│  │  ├─ store.py
│  │  ├─ path.py
│  │  └─ io.py
│  └─ commands
│     ├─ config.py
│     ├─ backup.py
│     ├─ restore.py
│     └─ verify.py
└─ scripts
   └─ bump_version_pyproject.py
```

Dev flow with **uv**:

```bash
uv venv
source .venv/bin/activate
uv pip install -e .
brave-sync --help
```

Bump version (version lives in `pyproject.toml`):

```bash
uv run python scripts/bump_version_pyproject.py 0.1.1
git commit -am "chore: bump version to 0.1.1"
git tag v0.1.1
git push && git push --tags
```

---

## Troubleshooting

- **`brave-sync: command not found`** → add `~/.local/bin` to your `PATH`.
- **Missing `rsync`** → install it (see Requirements).
- **On Linux Brave won’t close** → ensure `procps` (`pgrep`/`pkill`) is installed.
- **Dry run confusion** → `--dry-run` never writes; remove it to actually copy.

---

## License

MIT — see `LICENSE`.
