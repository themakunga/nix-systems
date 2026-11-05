"""Check AWS file rendering without decrypting credentials or activating a host."""

import configparser
import json
from pathlib import Path
import subprocess

expression = """
let f = builtins.getFlake REPO;
in builtins.mapAttrs (_: host: let c = host.config; in {
  profiles = c.my.cloudProfiles.aws or [];
  credentials = if (c.sops.templates or {}) ? aws-credentials then {
    inherit (c.sops.templates.aws-credentials) content path owner mode;
  } else null;
  config = if (c.sops.templates or {}) ? aws-config then {
    inherit (c.sops.templates.aws-config) content path owner mode;
  } else null;
  home = c.users.users.nicolas.home or null;
  placeholders = c.sops.placeholder or {};
}) (f.darwinConfigurations // f.nixosConfigurations)
""".replace("REPO", json.dumps(str(Path(__file__).resolve().parent.parent)))
hosts = json.loads(subprocess.check_output([
    "nix", "eval", "--impure", "--json", "--no-write-lock-file", "--expr", expression,
], text=True))
expected = {"kanagawa", "outer-heaven", "aperture-science"}
assert {name for name, data in hosts.items() if data["profiles"]} == expected
for name, data in hosts.items():
    if name not in expected:
        assert data["credentials"] is None and data["config"] is None
        continue

    credentials = configparser.RawConfigParser()
    credentials.read_string(data["credentials"]["content"])
    config = configparser.RawConfigParser()
    config.read_string(data["config"]["content"])
    assert set(credentials.sections()) == {p["name"] for p in data["profiles"]}
    for profile in data["profiles"]:
        name = profile["name"]
        for field in ("access_key_id", "secret_access_key"):
            assert credentials[name]["aws_" + field] == data["placeholders"][f"aws/credentials/{name}/{field}"]
        section = "default" if name == "default" else "profile " + name
        assert config[section]["region"] == profile["region"]
        assert config[section]["output"] == profile["output"]
    for kind in ("credentials", "config"):
        assert data[kind]["mode"] == "0600"
        assert data[kind]["owner"] == "nicolas"
        assert data[kind]["path"] == f"{data['home']}/.aws/{kind}"
    print("AWS profiles: SDK-compatible INI, SOPS placeholders and private file permissions OK")
