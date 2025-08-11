import typer

from .commands.config import register as register_config
from .commands.version import register as register_version
from .commands.backup import register as register_backup

app = typer.Typer(help="Brave Sync CLI")


# Register commands
for reg in (register_version, register_config, register_backup):
    reg(app)
