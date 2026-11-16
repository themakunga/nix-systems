#!/usr/bin/env python3
"""Evaluate real host integration and exercise Handy seeding without activation."""
import json
from pathlib import Path
import re
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
  inspect = host: let
    inherit (host) config pkgs;
    darwin = pkgs.stdenv.isDarwin;
    standalone = spec.sysConfig { inherit config pkgs; lib = pkgs.lib; };
  in {
    enabled = config.my.apps.handy.enable;
    platform = if darwin then "macos" else "linux";
    packages = map (p: p.pname or p.name) config.my.apps.handy.packages;
    casks = if darwin then map (c: c.name) config.homebrew.casks else [];
    launch = if darwin then config.launchd.user.agents.handy.serviceConfig.ProgramArguments else [];
    seed = if darwin then standalone.system.activationScripts.postActivation.text.content
      else standalone.system.activationScripts.seedHandy.text;
    deps = if darwin then [] else config.system.activationScripts.seedHandy.deps;
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
        for index, original in enumerate(homes):
            home = directory / f'home space {index}'
            home.mkdir()
            (home / '.public-dotfiles').symlink_to(dotfiles, target_is_directory=True)
            script = script.replace(original, str(home))
        subprocess.run(['bash', '-e', '-c', script], check=True, capture_output=True)
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
        for store in stores:
            store.unlink()
        for link in directory.glob('home space */.public-dotfiles'):
            link.unlink()
        failed = subprocess.run(['bash', '-e', '-c', script], capture_output=True)
        assert failed.returncode != 0, 'Missing public settings must not succeed silently'
    print(f'{hostname}: integration, first-run seeding, permissions, preservation and missing-source failure pass')
