from __future__ import annotations
from pathlib import Path

import typer


def get_version() -> str:
    """
    Return version from importlib.metadata (installed or editable).
    Fallback to reading pyproject.toml when running from source only.
    """
    try:
        from importlib.metadata import version, PackageNotFoundError

        try:
            return version("brave-sync")
        except PackageNotFoundError:
            pass
    except Exception:
        pass

    # Fallback: read pyproject (Python 3.11+ has tomllib)
    try:
        try:
            import tomllib  # type: ignore[attr-defined]
        except ModuleNotFoundError:
            tomllib = None  # type: ignore
        pyproject = Path(__file__).resolve().parents[2] / "pyproject.toml"
        if tomllib and pyproject.exists():
            data = tomllib.loads(pyproject.read_text(encoding="utf-8"))
            return data["project"]["version"]
    except Exception:
        pass

    return "0+unknown"


def register(app: typer.Typer) -> None:
    @app.command("version")
    def version_cmd() -> None:
        """Print the tool version (as declared in pyproject.toml)."""
        typer.echo(get_version())
