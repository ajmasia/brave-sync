from __future__ import annotations
from pathlib import Path
import typer

from .config import ensure_config
from ..core.io import ensure_brave_closed, rsync_copy, maybe_reopen_brave


def register(app: typer.Typer) -> None:
    @app.command("backup")
    def backup_cmd(
        dry_run: bool = typer.Option(
            False, "--dry-run", "-n", help="Print actions without modifying files"
        ),
    ) -> None:
        """
        Backup Brave profile items to the sync directory using rsync.
        The list of items comes from the user config.
        """
        cfg = ensure_config()
        ensure_brave_closed()

        items = cfg.items or []  # robust fallback
        if not items:
            typer.secho(
                "No items configured to back up. Run 'brave-sync config-items set ...'",
                fg=typer.colors.RED,
            )
            raise typer.Exit(2)

        dst_root = Path(cfg.sync_dir)
        dst_root.mkdir(parents=True, exist_ok=True)

        copied = 0
        for base in items:
            src = Path(cfg.brave_profile_dir) / base
            dst = dst_root / base
            if src.exists():
                rsync_copy(src, dst, dry_run=dry_run, delete=False)
                copied += 1
            else:
                typer.echo(f"Warning: {src} does not exist")

        msg = f"{copied}/{len(items)} items → {dst_root}"
        typer.echo(
            f"(dry-run) backup would copy {msg}" if dry_run else f"Backup done: {msg}"
        )

        maybe_reopen_brave(cfg.reopen_brave, dry_run)
