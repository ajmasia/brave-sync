from __future__ import annotations

import json
import os
from dataclasses import dataclass, asdict, fields, field
from pathlib import Path
from typing import Optional, List, Dict, Any
from platformdirs import user_config_path

APP_NAME = "brave-sync"
CONFIG_FILENAME = "config.json"

# Single default list, used for new configs or as fallback
DEFAULT_ITEMS: List[str] = [
    "Bookmarks",
    "Preferences",
    "Extensions",
    "Sync Data",
    "Web Data",
]


@dataclass
class Config:
    """Serializable user configuration stored as JSON."""

    brave_user_dir: str
    brave_profile: str = "Default"
    sync_dir: str = ""
    reopen_brave: bool = True
    items: List[str] = field(default_factory=lambda: list(DEFAULT_ITEMS))

    def __post_init__(self) -> None:
        # Backward-compat: if items is missing or null, use defaults
        if self.items is None:
            self.items = list(DEFAULT_ITEMS)

    @property
    def brave_profile_dir(self) -> Path:
        return Path(self.brave_user_dir) / self.brave_profile


def config_dir() -> Path:
    """Return config directory; allow override for dev/testing via env."""
    override = os.environ.get("BRAVE_SYNC_CONFIG_HOME")
    if override:
        return Path(override)
    return user_config_path(APP_NAME)


def config_path() -> Path:
    return config_dir() / CONFIG_FILENAME


def _filter_known_keys(data: Dict[str, Any]) -> Dict[str, Any]:
    """Filter JSON keys not present in the dataclass (forward-compat)."""
    allowed = {f.name for f in fields(Config)}
    return {k: v for k, v in data.items() if k in allowed}


def load_config() -> Optional[Config]:
    """Read config from disk, returning None if missing."""
    p = config_path()
    if not p.exists():
        return None
    data = json.loads(p.read_text(encoding="utf-8"))
    # Remove unknown keys and keep backward compatibility for 'items'
    data = _filter_known_keys(data)
    cfg = Config(**data)
    # Ensure items is always populated
    if not cfg.items:
        cfg.items = list(DEFAULT_ITEMS)
    return cfg


def save_config(cfg: Config) -> None:
    """Persist config atomically."""
    cfgdir = config_dir()
    cfgdir.mkdir(parents=True, exist_ok=True)
    tmp = cfgdir / (CONFIG_FILENAME + ".tmp")
    tmp.write_text(json.dumps(asdict(cfg), indent=2), encoding="utf-8")
    tmp.replace(config_path())
