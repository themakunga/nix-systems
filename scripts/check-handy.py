#!/usr/bin/env python3
"""Evaluate real host integration and exercise Handy seeding without activation."""
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
dotfiles = Path(sys.argv[1]).resolve()
expression = r'''
let
  f = builtins.getFlake ROOT;
  spec = (import (ROOT + "/modules/applications/handy.nix") {
    self.lib.mkAppModule = _: _: value: value;
  }).flake.applicationModules.handy;
  native = f.inputs.nixpkgs.legacyPackages.${builtins.currentSystem};
  inspect = host: let
    inherit (host) config pkgs;
    darwin = pkgs.stdenv.isDarwin;
    standalone = spec.sysConfig { inherit config pkgs; lib = pkgs.lib; };
    sync = (import (ROOT + "/modules/modules/common/dotfiles.nix") {})
      .flake.commonModules.dotfiles {
        lib = pkgs.lib;
        pkgs = pkgs // { git = native.git; };
        config.my.dotfiles = config.my.dotfiles // {
          packages = [];
          additionalUsers = map (u: u // { packages = []; }) config.my.dotfiles.additionalUsers;
        };
      };
  in {
    enabled = config.my.apps.handy.enable;
    platform = if darwin then "macos" else "linux";
    packages = map (p: p.pname or p.name) config.my.apps.handy.packages;
    casks = if darwin then map (c: c.name) config.homebrew.casks else [];
    launch = if darwin then config.launchd.user.agents.handy.serviceConfig.ProgramArguments else [];
    seed = if darwin then standalone.system.activationScripts.postActivation.text.content
      else standalone.system.activationScripts.seedHandy.text;
    deps = if darwin then [] else config.system.activationScripts.seedHandy.deps;
    sync = map (s: s.text) (builtins.attrValues sync.config.content.system.activationScripts);
  };
in (builtins.mapAttrs (_: inspect) f.darwinConfigurations) // {
  aperture-science = inspect f.nixosConfigurations.aperture-science;
}
'''.replace('ROOT', json.dumps(str(root)))
hosts = json.loads(subprocess.check_output(
    ['nix', 'eval', '--impure', '--json', '--expr', expression], text=True))
assert set(hosts) == {'kanagawa', 'outer-heaven', 'aperture-science'}, hosts.keys()
for hostname, host in hosts.items():
    assert host['enabled'], hostname
    macos = host['platform'] == 'macos'
    assert host['casks'].count('handy') == int(macos), hostname
    assert ('handy' in host['packages']) == (not macos), hostname
    if macos:
        assert host['launch'] == ['/Applications/Handy.app/Contents/MacOS/handy', '--start-hidden']
    else:
        assert {'handy', 'wtype', 'wl-clipboard'} <= set(host['packages'])
        assert {'users', 'stowDotfiles', 'stowDotfiles-nicolas'} <= set(host['deps'])
    with tempfile.TemporaryDirectory(prefix='handy-seed-') as temporary:
        directory = Path(temporary)
        sudo = directory / 'sudo'
        # Run generated Linux commands with the native shell when testing on macOS.
        sudo.write_text('#!/bin/sh\nshift 4\nexec bash "$@"\n')
        sudo.chmod(0o755)
        script = host['seed'].replace('/usr/bin/sudo', str(sudo)).replace('/run/wrappers/bin/sudo', str(sudo))
        homes = sorted(set(re.findall(r'"([^"\n]+)/\.public-dotfiles/handy/', script)))
        assert len(homes) == (1 if macos else 2), (hostname, homes)
        upstream = directory / 'upstream'
        upstream.mkdir()
        def git(*args, cwd=upstream):
            return subprocess.check_output([
                'git', '-c', 'user.name=Handy Test', '-c', 'user.email=test@example.invalid',
                '-c', 'commit.gpgsign=false', '-c', 'core.hooksPath=/dev/null',
                '-C', str(cwd), *args,
            ], text=True, stderr=subprocess.STDOUT)
        git('init', '-q', '-b', 'main')
        git('commit', '-q', '--allow-empty', '-m', 'Before Handy')
        git('branch', 'develop')
        sync = '\n'.join(host['sync'])
        sync = re.sub(r'run_as_user\(\) \{[^\n]+\}', 'run_as_user() { "$@"; }', sync)
        sync = 'chown() { :; }\n' + sync
        sync = sync.replace('https://github.com/themakunga/public-dotfiles.git', str(upstream))
        for index, original in enumerate(homes):
            home = directory / f'home space {index}'
            home.mkdir()
            subprocess.run(['git', 'clone', '-q', str(upstream), str(home / '.public-dotfiles')], check=True)
            if not macos and index == 0:
                subprocess.run(['git', '-C', str(home / '.public-dotfiles'), 'checkout', '-qb', 'develop'], check=True)
            script = script.replace(original, str(home))
            sync = sync.replace(original, str(home))
        shutil.copytree(dotfiles / 'handy', upstream / 'handy')
        git('add', 'handy')
        git('commit', '-q', '-m', 'Publish Handy settings on main')
        subprocess.run(['bash', '-e', '-c', sync], check=True, capture_output=True)
        seeded = subprocess.run(['bash', '-e', '-c', script], text=True, capture_output=True)
        assert seeded.returncode == 0, f'{hostname}: {seeded.stderr}'
        stores = list(directory.rglob('settings_store.json'))
        assert len(stores) == len(homes), hostname
        for store in stores:
            settings = json.loads(store.read_text())['settings']
            assert settings['selected_language'] == 'auto'
            assert not any(settings[k] for k in ('auto_submit', 'translate_to_english', 'post_process_enabled'))
            assert store.stat().st_mode & 0o777 == 0o600
            model = store.parent / 'models' / settings['selected_model'].rsplit('/', 1)[1]
            assert model.is_symlink(), model
            store.write_text('{"preserve": true}\n')
            model.unlink()
            model.write_text('existing user model')
        subprocess.run(['bash', '-e', '-c', script], check=True, capture_output=True)
        for store in stores:
            assert json.loads(store.read_text()) == {'preserve': True}
            assert next((store.parent / 'models').iterdir()).read_text() == 'existing user model'
        checkout = directory / 'home space 0/.public-dotfiles'
        assert git('branch', '--show-current', cwd=checkout).strip() == ('main' if macos else 'develop')
        source = checkout / f"handy/{host['platform']}-settings.json"
        source.write_text(source.read_text() + '\n')
        local_settings = source.read_bytes()
        published = upstream / source.relative_to(checkout)
        published.write_text(published.read_text() + '\n\n')
        git('commit', '-qam', 'Update public settings')
        original_head = git('rev-parse', 'HEAD', cwd=checkout)
        result = subprocess.run(['bash', '-e', '-c', sync], text=True, capture_output=True)
        assert result.returncode == 0 and 'could not fast-forward' in result.stderr
        assert source.read_bytes() == local_settings
        assert git('rev-parse', 'HEAD', cwd=checkout) == original_head
        git('commit', '-qam', 'Keep local settings', cwd=checkout)
        divergent_head = git('rev-parse', 'HEAD', cwd=checkout)
        result = subprocess.run(['bash', '-e', '-c', sync], text=True, capture_output=True)
        assert result.returncode == 0 and 'could not fast-forward' in result.stderr
        assert git('rev-parse', 'HEAD', cwd=checkout) == divergent_head
        assert source.read_bytes() == local_settings
        git('remote', 'set-url', 'origin', str(directory / 'unavailable'), cwd=checkout)
        result = subprocess.run(['bash', '-e', '-c', sync], text=True, capture_output=True)
        assert result.returncode == 0 and 'could not fast-forward' in result.stderr
        assert source.read_bytes() == local_settings
        for store in stores:
            store.unlink()
        for checkout in directory.glob('home space */.public-dotfiles'):
            shutil.rmtree(checkout)
        failed = subprocess.run(['bash', '-e', '-c', script], capture_output=True)
        assert failed.returncode != 0, 'Missing public settings must not succeed silently'
        subprocess.run(['bash', '-e', '-c', sync], check=True, capture_output=True)
        subprocess.run(['bash', '-e', '-c', script], check=True, capture_output=True)
    print(f'{hostname}: sync, seeding, permissions, local edits, divergence, offline and fresh clone pass')
