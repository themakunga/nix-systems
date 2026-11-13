"""Check the portable Compose contract without starting containers."""

import json
import os
import subprocess
from pathlib import Path

project = Path(__file__).resolve().parents[1] / "modules/applications/docker-host/umami"
command = ["docker-compose", "-f", str(project / "compose.yaml"), "--env-file", "/dev/null", "config"]
names = ("POSTGRES_PASSWORD", "APP_SECRET", "TWO_FACTOR_ENCRYPTION_KEY")
environment = {key: value for key, value in os.environ.items() if key not in (*names, "UMAMI_BIND_IP")}
environment.update({name: str(index) * 64 for index, name in enumerate(names, 1)})

for name in names:
    missing = environment.copy()
    del missing[name]
    result = subprocess.run(command + ["--quiet"], env=missing, capture_output=True)
    assert result.returncode != 0, f"Missing {name} must prevent startup"

for address in (None, "192.168.5.153", "192.168.1.10"):
    configured = environment.copy()
    if address:
        configured["UMAMI_BIND_IP"] = address
    result = subprocess.run(command + ["--format", "json"], env=configured, capture_output=True, check=True)
    compose = json.loads(result.stdout)
    app, database = compose["services"]["umami"], compose["services"]["db"]
    port, = app["ports"]
    assert port["host_ip"] == (address or "0.0.0.0")
    assert str(port["published"]) == "8989" and port["target"] == 3000
    assert not database.get("ports"), "PostgreSQL must remain unpublished"
    assert list(database["networks"]) == ["backend"]
    assert compose["networks"]["backend"]["internal"]
    assert app["environment"]["DATABASE_URL"] == (
        f"postgresql://umami:{database['environment']['POSTGRES_PASSWORD']}@db:5432/umami"
    )
    assert app["depends_on"]["db"]["condition"] == "service_healthy"
    volume, = database["volumes"]
    assert volume["type"] == "volume" and volume["target"] == "/var/lib/postgresql/data"
    assert compose["volumes"][volume["source"]]["name"] == "umami_umami-db-data"

print("Umami Compose checks passed: required secrets, portable LAN binding, database isolation and persistence.")
