#!/usr/bin/env python3
"""Exercise Wheatley's generated setup with local Git fixtures and no credentials."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
dotfiles, journal_skill = (Path(p).resolve() for p in sys.argv[1:3])
expression = r'''
let
  f = builtins.getFlake ROOT;
  config = f.nixosConfigurations.aperture-science.config;
  pkgs = f.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
  spec = (import (ROOT + "/modules/applications/agent-workspace.nix") {
    self.lib.mkAppModule = _: _: value: value;
  }).flake.applicationModules.agent-workspace;
  module = spec.sysConfig {inherit config pkgs; inherit (pkgs) lib;};
in {
  script = module.system.activationScripts.seedAgentWorkspace.text;
  token = config.sops.secrets."applications/gh/token".path;
}
'''.replace('ROOT', json.dumps(str(root)))
setup = (json.loads(Path(sys.argv[3]).read_text()) if len(sys.argv) > 3 else
         json.loads(subprocess.check_output(
             ['nix', 'eval', '--impure', '--json', '--expr', expression], text=True)))
with tempfile.TemporaryDirectory(prefix='agent-workspace-') as temporary:
    directory = Path(temporary).resolve()
    home = directory / 'wheatley'
    home.mkdir()
    env = dict(os.environ, GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1')
    upstream = directory / 'journal-upstream'
    upstream.mkdir()
    shared_config = (
        'authorized_dirs = []\n[core]\nname = "journal"\n'
        'path = "/Users/reference/.vaults/journal"\n[configuration]\n'
        'date_format = "yyyy-MM-dd"\ntime_format = "HH:mm"\n'
        'agents = ["Codex"]\n'
    )
    (upstream / '.journal.config.toml').write_text(shared_config)
    subprocess.run(['git', 'init', '-q', '-b', 'main', str(upstream)], check=True, env=env)
    subprocess.run(['git', '-C', str(upstream), 'add', '.'], check=True, env=env)
    subprocess.run(['git', '-C', str(upstream), '-c', 'user.name=Test', '-c',
                    'user.email=test@example.invalid', '-c', 'commit.gpgsign=false',
                    '-c', 'core.hooksPath=/dev/null', 'commit', '-qm', 'fixture'], check=True, env=env)
    sudo = directory / 'sudo'
    sudo.write_text('#!/bin/sh\nshift 3\nexec "$@"\n')
    sudo.chmod(0o755)
    token = directory / 'test-token'
    token.write_text('fixture-only\n')
    installed = home / '.vaults/amgmt/skills'
    installed.mkdir(parents=True)
    (installed / 'obsidian-journal').symlink_to(journal_skill)
    (installed / 'agent-glados').mkdir()
    (installed / 'agent-glados/SKILL.md').write_text('---\nname: glados\ndescription: Test\n---\n')
    config_source = home / '.public-dotfiles/agent/journal-settings.json'
    config_source.parent.mkdir(parents=True)
    config_source.write_bytes((dotfiles / 'agent/journal-settings.json').read_bytes())
    custom = home / '.codex/skills/ask-matt/SKILL.md'
    custom.parent.mkdir(parents=True)
    custom.write_text('Existing custom skill\n')
    auth = home / '.codex/auth.json'
    auth.write_text('{"fixture": "untouched"}\n')
    script = setup['script'].replace('/opt/wheatley', str(home))
    script = script.replace('/run/wrappers/bin/sudo', str(sudo))
    script = script.replace(setup['token'], str(token))
    script = script.replace('https://github.com/themakunga/journal.git', str(upstream))
    def activate():
        result = subprocess.run(['bash', '-eu', '-c', script], env=env,
                                capture_output=True, text=True)
        assert result.returncode == 0, result.stdout + result.stderr
    activate()
    journal = home / '.vaults/journal'
    local_config = home / '.config/obsidian-journal/config.toml'
    assert (journal / '.journal.config.toml').read_text() == shared_config
    assert (home / '.obsidian-journal-vault').read_text().strip() == str(journal)
    assert f'path = "{journal}"' in local_config.read_text()
    assert (home / '.vaults').stat().st_mode & 0o777 == 0o700
    assert not (home / '.agents/skills/ask-matt').exists()
    assert custom.read_text() == 'Existing custom skill\n'
    assert len(list((home / '.agents/skills').iterdir())) == 46
    assert (home / '.agents/skills/obsidian-journal').resolve() == journal_skill
    assert (home / '.agents/skills/glados/SKILL.md').is_file()
    original = local_config.read_bytes()
    activate()
    assert local_config.read_bytes() == original
    assert (journal / '.journal.config.toml').read_text() == shared_config
    assert auth.read_text() == '{"fixture": "untouched"}\n'
print('Workspace setup: shared config preserved, local journal valid, 45 skills linked, overrides and auth retained.')
