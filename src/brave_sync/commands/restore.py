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
    "Sync Data",
]


def register(app: typer.Typer) -> None:
    @app.command("restore")
    def restore_cmd(
        dry_run: bool = typer.Option(
            False, "--dry-run", "-n", help="Print actions without modifying files"
        ),
    ) -> None:
        """
        Restore from the sync directory into the Brave profile directory using rsync.
        - No sandbox, no extra flags.
        - Safe default: we do NOT mirror deletions on the profile side.
        """
        cfg = ensure_config()
        typer.echo(
            f"You are about to restore from {cfg.sync_dir} to {cfg.brave_profile_dir}"
        )
        if not typer.confirm("Continue?", default=False):
            raise typer.Abort()

        ensure_brave_closed()
        Path(cfg.brave_profile_dir).mkdir(parents=True, exist_ok=True)

        restored = 0
        for base in DEFAULT_ITEMS:
            src = Path(cfg.sync_dir) / base
            dst = Path(cfg.brave_profile_dir) / base
            if src.exists():
                rsync_copy(src, dst, dry_run=dry_run, delete=False)
                restored += 1
            else:
                typer.echo(f"Warning: {src} does not exist")

        msg = f"{restored}/{len(DEFAULT_ITEMS)} items → {cfg.brave_profile_dir}"
        typer.echo(
            f"(dry-run) restore would write {msg}"
            if dry_run
            else f"Restore done: {msg}"
        )
