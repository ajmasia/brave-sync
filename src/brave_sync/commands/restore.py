from __future__ import annotations
from pathlib import Path
import typer

from .config import ensure_config
from ..core.io import ensure_brave_closed, rsync_copy, maybe_reopen_brave


def register(app: typer.Typer) -> None:
    @app.command("restore")
    def restore_cmd(
        dry_run: bool = typer.Option(
            False, "--dry-run", "-n", help="Print actions without modifying files"
        ),
    ) -> None:
        """
        Restore from the sync directory into the Brave profile directory using rsync.
        The list of items comes from the user config.
        """
        cfg = ensure_config()
        items = cfg.items or []
        if not items:
            typer.secho(
                "No items configured to restore. Run 'brave-sync config-items set ...'",
                fg=typer.colors.RED,
            )
            raise typer.Exit(2)

        typer.echo(
            f"You are about to restore from {cfg.sync_dir} to {cfg.brave_profile_dir}"
        )
        if not typer.confirm("Continue?", default=False):
            raise typer.Abort()

        ensure_brave_closed()
        Path(cfg.brave_profile_dir).mkdir(parents=True, exist_ok=True)

        restored = 0
        for base in items:
            src = Path(cfg.sync_dir) / base
            dst = Path(cfg.brave_profile_dir) / base
            if src.exists():
                rsync_copy(src, dst, dry_run=dry_run, delete=False)
                restored += 1
            else:
                typer.echo(f"Warning: {src} does not exist")

        msg = f"{restored}/{len(items)} items → {cfg.brave_profile_dir}"
        typer.echo(
            f"(dry-run) restore would write {msg}"
            if dry_run
            else f"Restore done: {msg}"
        )

        maybe_reopen_brave(cfg.reopen_brave, dry_run)
