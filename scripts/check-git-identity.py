#!/usr/bin/env python3
"""Run with python3 scripts/check-git-identity.py; never activates the host."""

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
  module = (import (REPO + "/modules/modules/common/git-identity.nix"))
    .flake.commonModules.git-identity {
      inherit pkgs;
      lib = pkgs.lib;
      config = {
        system.primaryUser = "git-identity-test";
        programs.git-identity = {
          enable = true;
          global.enable = false;
          workspaces.demo = {
            directory = "git-test-project";
            realName = "Test User";
            email = "test@example.invalid";
            gpg.enable = false;
            ssh.enable = false;
          };
        };
      };
    };
in module.config.content.system.activationScripts.postActivation.text
'''.replace("REPO", json.dumps(str(repo)))
script = subprocess.check_output(
    ["nix", "eval", "--impure", "--raw", "--expr", expression], text=True
)
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    script = script.replace("/Users/git-identity-test", directory)
    script = "chown() { :; }\n" + script
    source = root / "public-gitconfig"
    source.write_text(f'[include]\n  path = {root}/.gitconfig.nix-managed\n[alias]\n  kept = status\n')
    (root / ".gitconfig").symlink_to(source)
    project = root / "git-test-project"
    project.mkdir()
    env = dict(os.environ, GIT_CONFIG_GLOBAL=str(root / ".gitconfig"), GIT_CONFIG_NOSYSTEM="1")
    subprocess.run(["git", "init", "-q", str(project)], check=True, env=env)
    for _ in range(2):
        subprocess.run(["bash", "-eu", "-c", script], check=True, env=env)
        def config(key):
            return subprocess.check_output(["git", "-C", str(project), "config", "--get", key], env=env, text=True).strip()
        assert config("pull.rebase") == "false"
        assert config("alias.kept") == "status"
        assert config("user.email") == "test@example.invalid"
    assert (root / ".gitconfig").is_symlink()
    assert source.read_text().count("[include]") == 1
    source.write_text('[include]\n  path = ~/.gitconfig.nix-managed\n')
    subprocess.run(["bash", "-eu", "-c", script], check=True, env=env)
    assert source.read_text().count("[include]") == 1
print("Git activation: pull strategy, workspace includes and idempotence OK")
