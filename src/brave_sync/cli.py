import typer

from .commands.config import register as register_config
from .commands.version import register as register_version

app = typer.Typer(help="Brave Sync CLI")


# Register commands
for reg in (register_version, register_config):
    reg(app)
