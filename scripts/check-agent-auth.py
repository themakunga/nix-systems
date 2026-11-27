#!/usr/bin/env python3
"""Exercise actual activation output without secrets, root or a system switch."""
import json
import os
import re
import shutil
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
expression = r'''
let
  f = builtins.getFlake ROOT;
  config = f.nixosConfigurations.aperture-science.config;
  pkgs = f.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
  spec = (import (ROOT + "/modules/applications/coding-agents.nix") {
    inherit (f) inputs;
    self.lib.mkAppModule = _: _: value: value;
  }).flake.applicationModules.coding-agents;
  module = spec.sysConfig {inherit config pkgs; inherit (pkgs) lib;};
  ub = (import (ROOT + "/modules/applications/ub-mode.nix") {
    self.lib.mkAppModule = _: _: value: value;
  }).flake.applicationModules.ub-mode;
  ubModule = ub.sysConfig {inherit config pkgs; inherit (pkgs) lib;};
  wikiModule = (import (ROOT + "/modules/modules/common/agent-wiki.nix") {}).flake.commonModules.agent-wiki;
  wiki = wikiModule {inherit config pkgs; inherit (pkgs) lib;};
  otherWiki = wikiModule {
    inherit pkgs; inherit (pkgs) lib;
    config = config // {my = config.my // {apps = config.my.apps // {coding-agents.enable = false; gemini-cli.enable = false;};};};
  };
in {
  wiki = wiki.config.content.system.activationScripts.postActivation.text.content;
  otherWiki = otherWiki.config.content.system.activationScripts.postActivation.text.content;
  skillSeed = ubModule.system.activationScripts.seedUbMode.text;
  token = config.sops.secrets."applications/gh/token".path;
  seed = module.system.activationScripts.seedCodingAgents.text;
  auth = config.sops.secrets.codex-auth.path;
  env = config.sops.templates."coding-agents-env".path;
}
'''.replace('ROOT', json.dumps(str(root)))
output = json.loads(subprocess.check_output(
    ['nix', 'eval', '--impure', '--json', '--expr', expression], text=True))
with tempfile.TemporaryDirectory(prefix='agent-auth-') as temporary:
    directory = Path(temporary).resolve()
    sudo = directory / 'sudo'
    sudo.write_text('#!/bin/sh\nshift 3\nexec "$@"\n')
    sudo.chmod(0o755)
    auth = directory / 'secret-auth'
    auth.write_text('{"test": "initial"}\n')
    environment = directory / 'secret-env'
    environment.write_text('GEMINI_API_KEY=test-only\n')
    skill_seed = output['skillSeed'].replace('/run/wrappers/bin/sudo', str(sudo))
    script = output['seed'].replace('/run/wrappers/bin/sudo', str(sudo))
    script = script.replace(output['auth'], str(auth)).replace(output['env'], str(environment))
    other_wiki = output['otherWiki'].replace(output['token'], str(auth))
    other_wiki = re.sub(r'run_as_user\(\) \{[^\n]+\}', 'run_as_user() { env HOME="$USER_HOME" "$@"; }', other_wiki)
    wiki = output['wiki'].replace(output['token'], str(auth))
    wiki = re.sub(r'run_as_user\(\) \{[^\n]+\}', 'run_as_user() { env HOME="$USER_HOME" "$@"; }', wiki)
    upstream = directory / 'upstream'
    (upstream / 'agents').mkdir(parents=True)
    (upstream / 'agents/SOUL.md').write_text('Test identity\n')
    (upstream / 'hooks').mkdir()
    (upstream / 'hooks/test').write_text('fixture\n')
    rules = upstream / 'stow/codex/.codex/rules/journal.rules'
    rules.parent.mkdir(parents=True)
    rules.write_text('# Managed journal rules fixture\n')
    command = upstream / 'stow/codex/.local/bin/journal-maintenance'
    command.parent.mkdir(parents=True)
    command.write_text('#!/bin/sh\nexit 0\n')
    command.chmod(0o755)
    env = dict(os.environ, GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1')
    subprocess.run(['git', 'init', '-q', '-b', 'main', str(upstream)], check=True, env=env)
    subprocess.run(['git', '-C', str(upstream), 'add', '.'], check=True, env=env)
    subprocess.run(['git', '-C', str(upstream), '-c', 'user.name=Test', '-c',
                    'user.email=test@example.invalid', '-c', 'commit.gpgsign=false',
                    '-c', 'core.hooksPath=/dev/null', 'commit', '-qm', 'fixture'], check=True, env=env)
    wiki = wiki.replace('https://github.com/themakunga/amgmt.git', str(upstream))
    other_wiki = other_wiki.replace('https://github.com/themakunga/amgmt.git', str(upstream))
    homes = [directory / 'wheatley', directory / 'nicolas']
    for original, home in zip(['/opt/wheatley', '/home/nicolas'], homes):
        script = script.replace(original, str(home))
        wiki = wiki.replace(original, str(home))
        other_wiki = other_wiki.replace(original, str(home))
        skill_seed = skill_seed.replace(original, str(home))
        source = home / '.public-dotfiles/hermes/config.aperture-science.yaml'
        source.parent.mkdir(parents=True)
        source.write_text('model:\n  provider: gemini\n')
        gh_source = home / '.public-dotfiles/gh/config.aperture-science.yml'
        gh_source.parent.mkdir(parents=True)
        gh_source.write_text('git_protocol: https\n')
        gemini_source = home / '.public-dotfiles/local-ai/templates/gemini-settings.json'
        gemini_source.parent.mkdir(parents=True)
        gemini_source.write_text('{"context":{"fileName":["AGENTS.md","GEMINI.md"]}}\n')
        local_rules = home / '.codex/rules/default.rules'
        local_rules.parent.mkdir(parents=True)
        local_rules.write_text('# Local rules preserved\n')
    existing_skill = homes[0] / '.claude/skills/ub-mode/SKILL.md'
    existing_skill.parent.mkdir(parents=True)
    existing_skill.write_text('Local skill preserved\n')
    def activate():
        subprocess.run(['bash', '-eu', '-c', script], check=True, env=env)
        subprocess.run(['bash', '-eu', '-c', wiki], check=True, env=env, capture_output=True)
        subprocess.run(['bash', '-eu', '-c', skill_seed], check=True, env=env)
    activate()
    for home in homes:
        assert 'name: ub-mode' in (home / '.agents/skills/ub-mode/SKILL.md').read_text()
        assert existing_skill.read_text() == 'Local skill preserved\n'
        destination = home / '.codex/auth.json'
        assert destination.read_bytes() == auth.read_bytes()
        assert destination.stat().st_mode & 0o777 == 0o600
        gh_config = home / '.config/gh/config.yml'
        assert gh_config.read_text() == 'git_protocol: https\n'
        assert gh_config.stat().st_mode & 0o777 == 0o600
        gh_config.write_text('local: preserved\n')
        assert not destination.is_symlink()
        repository = home / '.vaults/amgmt'
        credential = subprocess.check_output(['git', '-C', str(repository), 'config',
            '--get', 'credential.https://github.com.helper'], text=True, env=env)
        assert 'gh auth git-credential' in credential
        assert 'initial' not in (repository / '.git/config').read_text()
        assert (home / '.codex').stat().st_mode & 0o777 == 0o700
        assert (home / '.codex/AGENTS.md').resolve() == repository / 'agents/SOUL.md'
        assert (home / '.codex/rules/journal.rules').resolve() == repository / 'stow/codex/.codex/rules/journal.rules'
        assert (home / '.local/bin/journal-maintenance').resolve() == repository / 'stow/codex/.local/bin/journal-maintenance'
        assert (home / '.codex/rules/default.rules').read_text() == '# Local rules preserved\n'
        assert (home / '.hermes/.env').resolve() == environment
        assert (home / '.hermes/SOUL.md').read_text() == 'Test identity\n'
        assert (home / '.gemini/GEMINI.md').read_text() == 'Test identity\n'
        gemini_settings = home / '.gemini/settings.json'
        assert json.loads(gemini_settings.read_text())['context']['fileName'] == ['AGENTS.md', 'GEMINI.md']
        assert gemini_settings.stat().st_mode & 0o777 == 0o600
        gemini_settings.write_text('{"local":"preserved"}\n')
        destination.write_text('{"test": "refreshed"}\n')
        (home / '.hermes/config.yaml').write_text('local: preserved\n')
    activate()
    for home in homes:
        assert (home / '.codex/auth.json').read_text() == '{"test": "refreshed"}\n'
        assert (home / '.hermes/config.yaml').read_text() == 'local: preserved\n'
        assert (home / '.config/gh/config.yml').read_text() == 'local: preserved\n'
        assert (home / '.gemini/settings.json').read_text() == '{"local":"preserved"}\n'
    # A missing symlink target must not cause credential restoration over a runtime link.
    destination = homes[0] / '.codex/auth.json'
    destination.unlink()
    destination.symlink_to(directory / 'absent-runtime-auth')
    activate()
    assert destination.is_symlink() and not destination.exists()
    for home in homes:
        for identity in ['.hermes/SOUL.md', '.gemini/GEMINI.md']:
            path = home / identity
            path.unlink()
            path.write_text('Other host identity preserved\n')
    subprocess.run(['bash', '-eu', '-c', other_wiki], check=True, env=env, capture_output=True)
    for home in homes:
        for identity in ['.hermes/SOUL.md', '.gemini/GEMINI.md']:
            assert (home / identity).read_text() == 'Other host identity preserved\n'
        # Codex instructions must not depend on unrelated hook installation.
        (home / '.codex/AGENTS.md').unlink()
        shutil.rmtree(home / '.vaults/amgmt/hooks')
    subprocess.run(['bash', '-eu', '-c', wiki], check=True, env=env, capture_output=True)
    for home in homes:
        assert (home / '.codex/AGENTS.md').read_text() == 'Test identity\n'
print('Agent setup: private auth, writable refresh, vault clone, identities and preserved skills OK')
