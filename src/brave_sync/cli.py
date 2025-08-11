import typer

from .commands.config import register as register_config
from .commands.version import register as register_version
from .commands.backup import register as register_backup
from .commands.restore import register as register_restore
from .commands.verify import register as register_verify

app = typer.Typer(help="Brave Sync CLI")


# Register commands
for reg in (
    register_version,
    register_config,
    register_backup,
    register_restore,
    register_verify,
):
    reg(app)
