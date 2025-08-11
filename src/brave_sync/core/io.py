from __future__ import annotations

import shutil
import subprocess
from pathlib import Path
import typer
import sys
import time


def _pgrep_exact(names: list[str]) -> bool:
    """Return True if any process with an exact name in `names` is running."""
    for n in names:
        r = subprocess.run(
            ["pgrep", "-x", n],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if r.returncode == 0:
            return True
    return False


def _wait_until_gone(names: list[str], timeout_s: float) -> bool:
    """Wait until none of the exact-named processes are running."""
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        if not _pgrep_exact(names):
            return True
        time.sleep(0.25)
    return not _pgrep_exact(names)


def ensure_brave_closed(timeout_s: float = 8.0) -> None:
    """
    Try to close Brave gently on Linux/macOS/Windows (best-effort).
    - Linux: pkill exact names ('-x') to avoid killing 'brave-sync'.
    - macOS: ask the app to quit via AppleScript, then fall back to pkill exact names.
    - Windows: taskkill on brave.exe.
    Escalate to KILL if still alive after timeout.
    """
    if sys.platform.startswith("linux"):
        names = ["brave", "brave-browser"]
        # TERM exact matches (not -f!)
        for n in names:
            subprocess.run(
                ["pkill", "-TERM", "-x", n],
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        if not _wait_until_gone(names, timeout_s):
            # Escalate
            for n in names:
                subprocess.run(
                    ["pkill", "-KILL", "-x", n],
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
        return

    if sys.platform.startswith("darwin"):
        # Ask the app politely
        subprocess.run(
            ["osascript", "-e", 'tell application "Brave Browser" to quit'],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        # Some helpers might linger; try exact pkill on the binary name used on macOS
        names = ["Brave Browser"]
        if not _wait_until_gone(names, timeout_s):
            for n in names:
                subprocess.run(
                    ["pkill", "-KILL", "-x", n],
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
        return

    if sys.platform.startswith("win"):
        # /T kills child processes too; /F forces if needed
        subprocess.run(
            ["taskkill", "/IM", "brave.exe", "/T", "/F"],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        # No reliable wait without WMI; assume taskkill did its job.
        return

    # Fallback (unknown OS): do nothing
    return


def ensure_rsync_available() -> None:
    """
    Ensure 'rsync' binary is on PATH; raise a friendly error if not.
    """
    if shutil.which("rsync") is None:
        typer.secho(
            "ERROR: 'rsync' is not installed or not on PATH.\n"
            "Install it and try again (e.g. 'sudo apt install rsync' or 'brew install rsync').",
            fg=typer.colors.RED,
        )
        raise typer.Exit(code=127)


def rsync_copy(
    src: Path, dst: Path, dry_run: bool = False, delete: bool = False
) -> None:
    """
    Copy 'src' to 'dst' using rsync.

    - If 'src' is a directory, we copy its *contents* (trailing slash) into 'dst' and
      optionally mirror deletions with --delete.
    - If 'src' is a file, we copy the file to 'dst' (which can be a file path or a directory).

    'dst' parent directories will be created if needed.
    """
    ensure_rsync_available()

    # Ensure destination parent exists
    dst.parent.mkdir(parents=True, exist_ok=True)

    args = ["rsync", "-a", "--human-readable"]

    if dry_run:
        # -n prints what would happen; -v gives visibility
        args += ["-n", "-v"]

    if src.is_dir():
        # Copy directory contents: add trailing '/' in src and dst
        src_spec = str(src) + "/"
        dst_spec = str(dst) + "/"
        if delete:
            args.append("--delete")
    else:
        # Copy a single file
        src_spec = str(src)
        dst_spec = str(dst)

    # Run rsync
    copy_cmd = args + ["--", src_spec, dst_spec]
    completed = subprocess.run(copy_cmd)

    if completed.returncode != 0:
        raise typer.Exit(code=completed.returncode)
