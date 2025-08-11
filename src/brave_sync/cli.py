import typer


print("Brave Sync CLI is starting...")
app = typer.Typer(help="Brave Sync CLI")


@app.command()
def hello(name: str):
    print(f"Hello {name}")
