from __future__ import annotations
from pathlib import Path

import sys
import os


def detect_brave_user_dir() -> Path:
    """Return the most likely Brave 'User Data' directory for the host OS."""
    home = Path.home()
    if sys.platform.startswith("linux"):
        return home / ".config" / "BraveSoftware" / "Brave-Browser"
    if sys.platform == "darwin":
        return (
            home / "Library" / "Application Support" / "BraveSoftware" / "Brave-Browser"
        )
    if sys.platform.startswith("win"):
        local = os.environ.get("LOCALAPPDATA", str(home / "AppData" / "Local"))
        return Path(local) / "BraveSoftware" / "Brave-Browser" / "User Data"
    return home / ".config" / "BraveSoftware" / "Brave-Browser"


def detect_profile(root: Path) -> str:
    """Return 'Default' or the first 'Profile *' directory found."""
    if (root / "Default").is_dir():
        return "Default"
    for p in sorted(root.glob("Profile *")):
        if p.is_dir():
            return p.name
    return "Default"


def detect_sync_dir() -> Path:
    """Prefer Nextcloud if present, otherwise a folder in the user's HOME."""
    home = Path.home()
    if (home / "Nextcloud").exists():
        return home / "Nextcloud" / "data" / "brave-sync"
    return home / "brave-sync"
