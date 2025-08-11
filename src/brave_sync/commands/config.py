from __future__ import annotations
from pathlib import Path
import typer

from ..core.store import (
    Config,
    load_config,
    save_config,
    config_path,
    DEFAULT_ITEMS,
)
from ..core.path import detect_brave_user_dir, detect_profile, detect_sync_dir


def ensure_config() -> Config:
    """
    Ensure a configuration exists. If missing, ask the user and persist it.
    Also ensures 'items' is set (defaults to DEFAULT_ITEMS).
    """
    cfg = load_config()
    if cfg:
        # Backward-compat: if an old config lacks items, set and save once
        if not cfg.items:
            cfg.items = list(DEFAULT_ITEMS)
            save_config(cfg)
        return cfg

    root = typer.prompt(
        "Path to Brave 'User Data'", default=str(detect_brave_user_dir())
    )
    prof = typer.prompt("Brave profile to sync", default=detect_profile(Path(root)))
    sync = typer.prompt("Local folder for backups/sync", default=str(detect_sync_dir()))
    reopen = typer.confirm("Reopen Brave after operations?", default=True)

    # Start with defaults; can be edited later with `config items`
    cfg = Config(
        brave_user_dir=root,
        brave_profile=prof,
        sync_dir=sync,
        reopen_brave=reopen,
        items=list(DEFAULT_ITEMS),
    )

    typer.echo(
        f"\nSummary:\n  brave_user_dir={cfg.brave_user_dir}\n"
        f"  brave_profile={cfg.brave_profile}\n"
        f"  sync_dir={cfg.sync_dir}\n"
        f"  reopen_brave={cfg.reopen_brave}\n"
        f"  items={', '.join(cfg.items)}\n"
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

    # Optional subcommand to edit the items list interactively
    items_app = typer.Typer(help="Edit the list of items (files/dirs) to sync.")
    app.add_typer(items_app, name="config-items")

    @items_app.command("show")
    def show_items() -> None:
        """Show the current items list from config."""
        cfg = ensure_config()
        for i, name in enumerate(cfg.items, 1):
            typer.echo(f"{i}. {name}")

    @items_app.command("set")
    def set_items(
        items_csv: str = typer.Argument(
            ",".join(DEFAULT_ITEMS),
            help="Comma-separated items. Example: 'Bookmarks,Preferences,History,Extensions,Sync Data'",
        ),
    ) -> None:
        """Replace the current items list with the provided CSV."""
        parts = [p.strip() for p in items_csv.split(",") if p.strip()]
        if not parts:
            typer.secho("Empty items list is not allowed.", fg=typer.colors.RED)
            raise typer.Exit(2)
        cfg = ensure_config()
        cfg.items = parts
        save_config(cfg)
        typer.secho("Items updated:", fg=typer.colors.GREEN)
        for i, name in enumerate(cfg.items, 1):
            typer.echo(f"{i}. {name}")
