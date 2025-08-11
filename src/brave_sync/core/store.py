from __future__ import annotations

import json
import os

from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Optional
from platformdirs import user_config_path

APP_NAME = "brave-sync"
CONFIG_FILENAME = "config.json"


@dataclass
class Config:
    """Serializable user configuration stored as JSON."""

    brave_user_dir: str
    brave_profile: str = "Default"
    sync_dir: str = ""
    reopen_brave: bool = True

    @property
    def brave_profile_dir(self) -> Path:
        return Path(self.brave_user_dir) / self.brave_profile


def config_dir() -> Path:
    """Return config directory; allow override for dev sandbox."""
    override = os.environ.get("BRAVE_SYNC_CONFIG_HOME")
    if override:
        return Path(override)
    return user_config_path(APP_NAME)


def config_path() -> Path:
    return config_dir() / CONFIG_FILENAME


def load_config() -> Optional[Config]:
    """Read config from disk, returning None if missing."""
    p = config_path()
    if not p.exists():
        return None
    data = json.loads(p.read_text(encoding="utf-8"))
    return Config(**data)


def save_config(cfg: Config) -> None:
    """Persist config atomically."""
    cfgdir = config_dir()
    cfgdir.mkdir(parents=True, exist_ok=True)
    tmp = cfgdir / (CONFIG_FILENAME + ".tmp")
    tmp.write_text(json.dumps(asdict(cfg), indent=2), encoding="utf-8")
    tmp.replace(config_path())
