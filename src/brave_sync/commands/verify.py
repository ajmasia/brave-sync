from __future__ import annotations
from pathlib import Path
from typing import List
import subprocess
import typer

from .config import ensure_config
from ..core.io import ensure_rsync_available

# Same items used in backup/restore (files + directories)
DEFAULT_ITEMS: List[str] = [
    "Bookmarks",
    "Preferences",
    "History",
    "Extensions",
    "Sync Data",
]


def _rsync_preview(src: Path, dst_dir: Path) -> list[str]:
    """
    Run rsync in dry-run mode from 'src' into 'dst_dir' (destination is a directory).
    Returns a parsed list of itemized-change lines (what would change).
    """
    ensure_rsync_available()
    dst_dir.mkdir(parents=True, exist_ok=True)

    # We mimic `rsync -a "$SRC" "$DST_DIR/"` and add:
    #  -n (dry-run)
    #  --delete       (to detect deletions when src is a directory)
    #  --itemize-changes + --out-format to get a stable, parseable output
    args = [
        "rsync",
        "-a",
        "-n",
        "--delete",
        "--itemize-changes",
        "--human-readable",
        "--out-format=%i %n%L",
        "--",
        str(src),  # no trailing slash on purpose
        str(dst_dir) + "/",  # destination is always a directory
    ]

    res = subprocess.run(args, capture_output=True, text=True)
    # rsync may return 23 if some files vanish during scan; treat it as non-fatal for a preview
    if res.returncode not in (0, 23):
        typer.secho(
            f"rsync preview failed (code {res.returncode})", fg=typer.colors.RED
        )
        raise typer.Exit(code=res.returncode)

    lines = [ln.strip() for ln in res.stdout.splitlines() if ln.strip()]
    # Filter out rsync summaries if any slipped; with --out-format we mostly get only changes.
    return lines


def register(app: typer.Typer) -> None:
    @app.command("verify")
    def verify_cmd() -> None:
        """
        Show what would change if you run 'backup' and 'restore' (both directions),
        without modifying any file. Uses rsync in dry-run mode.
        """
        cfg = ensure_config()
        profile_dir = Path(cfg.brave_user_dir) / cfg.brave_profile
        sync_dir = Path(cfg.sync_dir)

        if not profile_dir.exists():
            typer.secho(f"Profile dir not found: {profile_dir}", fg=typer.colors.RED)
            raise typer.Exit(1)
        sync_dir.mkdir(parents=True, exist_ok=True)

        total_up = 0  # profile -> sync (what backup would copy/remove)
        total_down = 0  # sync -> profile (what restore would copy/remove)

        typer.echo(
            f"Verifying differences between:\n  PROFILE: {profile_dir}\n  SYNC   : {sync_dir}\n"
        )

        for base in DEFAULT_ITEMS:
            src_profile_item = profile_dir / base
            src_sync_item = sync_dir / base

            # Skip items that don't exist on either side (but report)
            exists_profile = src_profile_item.exists()
            exists_sync = src_sync_item.exists()

            typer.echo(f"[{base}]")
            if not exists_profile and not exists_sync:
                typer.echo("  • Missing on both sides; nothing to compare.\n")
                continue

            # Preview: what backup would do (profile -> sync_dir/)
            up_lines = (
                _rsync_preview(src_profile_item, sync_dir) if exists_profile else []
            )
            # Preview: what restore would do (sync -> profile_dir/)
            down_lines = (
                _rsync_preview(src_sync_item, profile_dir) if exists_sync else []
            )

            total_up += len(up_lines)
            total_down += len(down_lines)

            if up_lines:
                typer.secho("  ↑ backup would change:", fg=typer.colors.YELLOW)
                for ln in up_lines:
                    typer.echo(f"    {ln}")
            else:
                typer.echo("  ↑ backup: no changes")

            if down_lines:
                typer.secho("  ↓ restore would change:", fg=typer.colors.YELLOW)
                for ln in down_lines:
                    typer.echo(f"    {ln}")
            else:
                typer.echo("  ↓ restore: no changes")

            typer.echo("")  # blank line between items

        typer.secho(
            f"Summary: backup would change {total_up} item(s); "
            f"restore would change {total_down} item(s).",
            fg=typer.colors.GREEN
            if (total_up == 0 and total_down == 0)
            else typer.colors.YELLOW,
            bold=True,
        )
