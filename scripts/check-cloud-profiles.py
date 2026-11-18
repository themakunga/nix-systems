"""Check AWS file rendering without decrypting credentials or activating a host."""

import configparser
import json
from pathlib import Path
import subprocess
import re
import tempfile
import shlex

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
  script = if host.pkgs.stdenv.hostPlatform.isDarwin then
    c.system.activationScripts.postActivation.text
    else c.system.activationScripts.cloudProfilesSetup.text or "";
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
    setup = re.search(r'^AWS_DIR=.*?^chown .*$', data["script"], re.M | re.S)
    assert setup, name
    # Stop at this block's chown rather than executing the rest of activation.
    script = setup[0].split('"$AWS_DIR/"', 1)[0] + '"$AWS_DIR/"\n'
    for case in ("missing", "directory", "symlink", "dangling", "file"):
        with tempfile.TemporaryDirectory(prefix="aws setup ") as directory:
            root = Path(directory)
            target = root / ".aws"
            if case == "directory":
                target.mkdir()
            elif case == "symlink":
                (root / "existing").mkdir()
                target.symlink_to(root / "existing")
            elif case == "dangling":
                target.symlink_to(".dotfiles/.aws")
            elif case == "file":
                target.write_text("preserve")
            if target.is_dir():
                (target / "credentials").write_text("preserve")
            fixture = re.sub(r'^AWS_DIR=.*$', 'AWS_DIR=' + shlex.quote(str(target)), script, count=1, flags=re.M)
            for _ in range(2):
                result = subprocess.run(["bash", "-eu", "-c", 'chown() { :; }\n' + fixture], capture_output=True, text=True)
                assert (result.returncode == 0) == (case != "file"), (name, case, result.stderr)
            if case == "file":
                assert target.read_text() == "preserve"
                continue
            assert target.is_dir()
            assert target.stat().st_mode & 0o777 == 0o700
            if case in ("directory", "symlink"):
                assert (target / "credentials").read_text() == "preserve"
            if case == "dangling":
                backups = list(root.glob(".aws.broken-link.*"))
                assert len(backups) == 1 and backups[0].readlink() == Path(".dotfiles/.aws")
    print("AWS profiles: SDK-compatible INI, SOPS placeholders and private file permissions OK")
