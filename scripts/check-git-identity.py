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
          projectRoot = null;
          global.enable = false;
          workspaces.demo = {
            directory = "~/.vaults";
            realName = "Test User";
            email = "test@example.invalid";
            gpg.enable = false;
            ssh = {
              enable = true;
              privateKey = "/test/personal-key";
            };
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
    root = Path(directory).resolve()
    directory = str(root)
    script = script.replace("/Users/git-identity-test", directory)
    script = "chown() { :; }\n" + script
    source = root / "public-gitconfig"
    source.write_text(f'[include]\n  path = {root}/.gitconfig.nix-managed\n[alias]\n  kept = status\n')
    (root / ".gitconfig").symlink_to(source)
    project = root / ".vaults/journal"
    project.mkdir(parents=True)
    env = dict(os.environ, GIT_CONFIG_GLOBAL=str(root / ".gitconfig"), GIT_CONFIG_NOSYSTEM="1")
    env["HOME"] = directory
    subprocess.run(["git", "init", "-q", str(project)], check=True, env=env)
    for _ in range(2):
        subprocess.run(["bash", "-eu", "-c", script], check=True, env=env)
        def config(key):
            return subprocess.check_output(["git", "-C", str(project), "config", "--get", key], env=env, text=True).strip()
        assert config("pull.rebase") == "false"
        assert config("alias.kept") == "status"
        assert config("user.email") == "test@example.invalid"
        assert config("core.sshCommand") == "ssh -i /test/personal-key -o IdentitiesOnly=yes -o AddKeysToAgent=yes -o UseKeychain=yes"
    assert (root / ".gitconfig").is_symlink()
    assert source.read_text().count("[include]") == 1
    source.write_text('[include]\n  path = ~/.gitconfig.nix-managed\n')
    subprocess.run(["bash", "-eu", "-c", script], check=True, env=env)
    assert source.read_text().count("[include]") == 1
    bin_dir = root / "bin"
    bin_dir.mkdir()
    ssh = bin_dir / "ssh"
    ssh.write_text('#!/bin/sh\nprintf "%s\\n" "$@" > "$SSH_TEST_LOG"\nexit 1\n')
    ssh.chmod(0o755)
    log = root / "ssh-args"
    clone_env = dict(env, PATH=str(bin_dir) + os.pathsep + env["PATH"],
                     SSH_TEST_LOG=str(log), GIT_SSH_VARIANT="ssh")
    result = subprocess.run(
        ["git", "clone", "ssh://git@example.invalid/repo", str(root / ".vaults/cloned")],
        env=clone_env, text=True, capture_output=True,
    )
    assert result.returncode != 0  # The fake SSH command never contacts a server.
    assert "/test/personal-key" in log.read_text()
print("Git activation: vault identity, SSH selection during clone and idempotence OK")
