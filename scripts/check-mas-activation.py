"""Run: python3 scripts/check-mas-activation.py (no installation or activation)."""

import json
from pathlib import Path
import re
import subprocess


repo = Path(__file__).resolve().parent.parent
hosts = json.loads(subprocess.check_output(
    ["nix", "eval", "--json", "--no-write-lock-file", ".#darwinConfigurations",
     "--apply", """builtins.mapAttrs (_: host: {
       script = host.config.system.activationScripts.postActivation.text;
       user = host.config.system.primaryUser;
       apps = host.config.my.masApps;
     })"""], cwd=repo, text=True,
))

for name, host in hosts.items():
    block = re.search(
        r'^echo "=> Instalando apps de Mac App Store.*?(?=^echo "=>|\Z)',
        host["script"], re.MULTILINE | re.DOTALL,
    )
    assert block, f"{name}: missing Mac App Store activation"
    uid = subprocess.check_output(["/usr/bin/id", "-u", host["user"]], text=True).strip()
    gid = subprocess.check_output(["/usr/bin/id", "-g", host["user"]], text=True).strip()
    # Reproduce mas 7's sudo identity requirement without contacting the App Store.
    mock = f'''
mas() {{
  [ "${{SUDO_UID:-}}" = "{uid}" ] || {{ echo "Error: Failed to get sudo uid"; return 1; }}
  [ "${{SUDO_GID:-}}" = "{gid}" ] || {{ echo "Error: Failed to get sudo gid"; return 1; }}
  echo "mas-call: $*"
  [ "$2" != "937984704" ]
}}
'''
    script = mock + block[0].replace("/opt/homebrew/bin/mas", "mas")
    for inherited in ({}, {"SUDO_UID": "0", "SUDO_GID": "0"}):
        result = subprocess.run(
            ["/bin/bash", "-eu", "-c", script],
            env={"PATH": "/usr/bin:/bin", **inherited}, text=True, capture_output=True,
        )
        assert result.returncode == 0, result.stderr
        assert "Failed to get sudo" not in result.stdout, result.stdout
        assert "WARNING: Amphetamine (937984704) omitida" in result.stdout, result.stdout
        for app_id in host["apps"].values():
            assert f"mas-call: install {app_id}\n" in result.stdout, result.stdout
    print(f"{name}: sudo identity restored; app failures remain non-fatal")
