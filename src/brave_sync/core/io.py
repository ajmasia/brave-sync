from __future__ import annotations
import shutil
import subprocess
from pathlib import Path
import sys
import time
import typer


def _pgrep_exact(names: list[str]) -> bool:
    for n in names:
        r = subprocess.run(
            ["pgrep", "-x", n], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        if r.returncode == 0:
            return True
    return False


def _wait_until_gone(names: list[str], timeout_s: float) -> bool:
    deadline = time.time() + timeout_s
    while time.time() < deadline:
        if not _pgrep_exact(names):
            return True
        time.sleep(0.25)
    return not _pgrep_exact(names)


def ensure_brave_closed(timeout_s: float = 8.0) -> None:
    """Close Brave gently per-OS without matar 'brave-sync' por error."""
    if sys.platform.startswith("linux"):
        names = ["brave", "brave-browser"]
        for n in names:
            subprocess.run(
                ["pkill", "-TERM", "-x", n],
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        if not _wait_until_gone(names, timeout_s):
            for n in names:
                subprocess.run(
                    ["pkill", "-KILL", "-x", n],
                    check=False,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
        return

    if sys.platform == "darwin":
        subprocess.run(
            ["osascript", "-e", 'tell application "Brave Browser" to quit'],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
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
        subprocess.run(
            ["taskkill", "/IM", "brave.exe", "/T", "/F"],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return


def _ensure_rsync() -> None:
    if shutil.which("rsync") is None:
        typer.secho(
            "ERROR: 'rsync' not found. Install it (apt/brew) and retry.",
            fg=typer.colors.RED,
        )
        raise typer.Exit(127)


def rsync_copy(
    src: Path, dst: Path, *, dry_run: bool = False, delete: bool = False
) -> None:
    """
    Copy 'src' into 'dst' using rsync.

    Your usage passes:
      - FILES:  rsync_copy(<profile>/<file>, <sync>/<file>)
      - DIRS:   rsync_copy(<profile>/Extensions, <sync>/Extensions)

    Semantics we implement:
      - FILE  -> FILE:   rsync SRC  DST
      - DIR   -> DIR:    ensure DST exists, rsync SRC/  DST/   (copy contents)
      - '--delete' only applies for directories (safe default: False)
    """
    _ensure_rsync()

    args = ["rsync", "-a", "--human-readable"]
    if dry_run:
        args += ["-n", "-v", "--stats"]
    if delete and src.is_dir():
        args.append("--delete")

    if src.is_dir():
        # Make sure destination directory exists, then copy *contents* of src into it
        dst.mkdir(parents=True, exist_ok=True)
        src_spec = str(src) + "/"  # copy contents
        dst_spec = str(dst) + "/"  # treat as directory
    else:
        # File-to-file copy; ensure parent exists
        dst.parent.mkdir(parents=True, exist_ok=True)
        src_spec = str(src)
        dst_spec = str(dst)

    # Run rsync (treat code 23 as non-fatal if something vanishes; usually OK after closing Brave)
    completed = subprocess.run(["rsync", *args[1:], "--", src_spec, dst_spec])
    if completed.returncode not in (0, 23):
        raise typer.Exit(completed.returncode)


def is_brave_running() -> bool:
    """Best-effort check if Brave is currently running."""
    if sys.platform.startswith("linux"):
        return _pgrep_exact(["brave", "brave-browser"])
    if sys.platform == "darwin":
        return _pgrep_exact(["Brave Browser"])
    if sys.platform.startswith("win"):
        try:
            out = subprocess.run(
                ["tasklist", "/FI", "IMAGENAME eq brave.exe"],
                capture_output=True,
                text=True,
                check=False,
            ).stdout.lower()
            return "brave.exe" in out
        except Exception:
            return False
    return False


def launch_brave() -> bool:
    """Try to (re)launch Brave on the current OS. Returns True on success."""
    try:
        if sys.platform.startswith("linux"):
            candidates = [
                ["brave"],
                ["brave-browser"],
                ["flatpak", "run", "com.brave.Browser"],
                ["snap", "run", "brave"],
            ]
            for cmd in candidates:
                if shutil.which(cmd[0]):
                    subprocess.Popen(
                        cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
                    )
                    return True
            return False

        if sys.platform == "darwin":
            subprocess.Popen(
                ["open", "-a", "Brave Browser"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return True

        if sys.platform.startswith("win"):
            # 'start' is a shell built-in, so use shell=True
            subprocess.Popen('start "" brave.exe', shell=True)
            return True
    except Exception:
        return False
    return False


def maybe_reopen_brave(reopen: bool, dry_run: bool) -> None:
    """
    Reopen Brave if requested, not in dry-run, and it's not already running.
    """
    if not reopen or dry_run:
        return
    # Give the OS a beat after closing to release locks
    time.sleep(0.5)
    if is_brave_running():
        return
    if not launch_brave():
        typer.echo("Warning: could not relaunch Brave (binary not found on PATH?).")
