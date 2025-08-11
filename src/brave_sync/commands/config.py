from __future__ import annotations
from pathlib import Path
import typer

from ..core.store import Config, load_config, save_config, config_path
from ..core.path import detect_brave_user_dir, detect_profile, detect_sync_dir


def ensure_config() -> Config:
    """
    Ensure a configuration exists. If missing, ask the user and persist it.
    No sandbox, no extra flags.
    """
    cfg = load_config()
    if cfg:
        return cfg

    # Ask the user, proposing sensible OS-based defaults
    root = typer.prompt(
        "Path to Brave 'User Data'", default=str(detect_brave_user_dir())
    )
    prof = typer.prompt("Brave profile to sync", default=detect_profile(Path(root)))
    sync = typer.prompt("Local folder for backups/sync", default=str(detect_sync_dir()))
    reopen = typer.confirm("Reopen Brave after operations?", default=True)

    cfg = Config(
        brave_user_dir=root, brave_profile=prof, sync_dir=sync, reopen_brave=reopen
    )
    typer.echo(
        f"\nSummary:\n  brave_user_dir={cfg.brave_user_dir}\n"
        f"  brave_profile={cfg.brave_profile}\n"
        f"  sync_dir={cfg.sync_dir}\n"
        f"  reopen_brave={cfg.reopen_brave}\n"
    )
    if typer.confirm(f"Save to {config_path()}?", default=True):
        save_config(cfg)
    return cfg


def register(app: typer.Typer) -> None:
    @app.command("config")
    def config_cmd() -> None:
        """Create/edit configuration interactively and persist it."""
        cfg = ensure_config()
        save_config(cfg)
        typer.echo(f"Config saved at {config_path()}")
