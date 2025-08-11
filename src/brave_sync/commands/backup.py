from __future__ import annotations
from pathlib import Path
from typing import List
import typer

from .config import ensure_config
from ..core.io import ensure_brave_closed, rsync_copy

DEFAULT_ITEMS: List[str] = [
    "Bookmarks",
    "Preferences",
    "History",
    "Extensions",
    "Login Data",
]


def register(app: typer.Typer) -> None:
    @app.command("backup")
    def backup_cmd(
        dry_run: bool = typer.Option(
            False, "--dry-run", "-n", help="Print actions without modifying files"
        ),
    ) -> None:
        """
        Backup Brave profile items to the sync directory using rsync.
        - No sandbox, no extra flags.
        - Safe default: we do NOT mirror deletions (no --delete).
        """
        cfg = ensure_config()
        ensure_brave_closed()

        dst_root = Path(cfg.sync_dir)
        dst_root.mkdir(parents=True, exist_ok=True)

        copied = 0
        for base in DEFAULT_ITEMS:
            src = Path(cfg.brave_profile_dir) / base
            dst = dst_root / base
            if src.exists():
                # delete=False for safety (no mirroring of deletions)
                rsync_copy(src, dst, dry_run=dry_run, delete=False)
                copied += 1
            else:
                typer.echo(f"Warning: {src} does not exist")

        msg = f"{copied}/{len(DEFAULT_ITEMS)} items → {dst_root}"
        typer.echo(
            f"(dry-run) backup would copy {msg}" if dry_run else f"Backup done: {msg}"
        )
