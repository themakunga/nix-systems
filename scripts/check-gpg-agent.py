"""Run: python3 scripts/check-gpg-agent.py (no real agent or user settings touched)."""

import getpass
import json
import os
from pathlib import Path
import subprocess
import tempfile


repo = Path(__file__).resolve().parent.parent
expression = '''
let
  flake = builtins.getFlake REPO;
  pkgs = flake.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
  module = (import (REPO + "/modules/modules/darwin/common.nix"))
    .flake.darwinModules.extras {
      inherit pkgs;
      lib = pkgs.lib;
      config = {
        system.primaryUser = USER;
        users.users.${USER}.home = "/Users/gpg-agent-test";
      };
    };
in module.system.activationScripts.postActivation.text.content
'''.replace("REPO", json.dumps(str(repo))).replace("USER", json.dumps(getpass.getuser()))
script = subprocess.check_output(
    ["nix", "eval", "--impure", "--raw", "--expr", expression], text=True,
)
for initial in (None, "default-cache-ttl 123\n", "pinentry-program /custom/pinentry\n"):
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory).resolve()
        config = root / ".gnupg/gpg-agent.conf"
        if initial is not None:
            config.parent.mkdir()
            config.write_text(initial)
        log = root / "reloads"
        isolated = 'sudo() { echo reload >> "$RELOAD_LOG"; }\n' + script.replace("/Users/gpg-agent-test", str(root))
        for _ in range(2):
            subprocess.run(["bash", "-eu", "-c", isolated], check=True,
                           env=dict(os.environ, RELOAD_LOG=str(log)))
        if initial and initial.startswith("pinentry-program"):
            assert config.read_text() == initial
            assert not log.exists()
        else:
            assert config.read_text() == (initial or "") + "\npinentry-program /run/current-system/sw/bin/pinentry\n"
            assert config.stat().st_mode & 0o777 == 0o600
            assert log.read_text() == "reload\n"
print("GPG pinentry: initial setup, config preservation and idempotence OK")
