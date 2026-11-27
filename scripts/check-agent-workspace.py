#!/usr/bin/env python3
"""Check generated cross-host workspace wiring and exercise public setup helpers."""
import json
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
dotfiles = Path(sys.argv[1]).resolve()
expression = r'''
let
  f = builtins.getFlake ROOT;
in {
  mac = builtins.mapAttrs (_: h: h.config.system.activationScripts.postActivation.text) f.darwinConfigurations;
  aperture = f.nixosConfigurations.aperture-science.config.system.activationScripts.seedAgentWorkspace.text;
}
'''.replace('ROOT', json.dumps(str(root)))
wiring = json.loads(subprocess.check_output(['nix', 'eval', '--impure', '--json', '--expr', expression], text=True))
for host in ['kanagawa', 'outer-heaven']:
    assert 'shared-workspace.py' in wiring['mac'][host]
    assert '--skills ' in wiring['mac'][host] and '--ub-skill ' in wiring['mac'][host]
for home in ['/opt/wheatley', '/home/nicolas', '/opt/glados', '/opt/hermes']:
    assert home in wiring['aperture'], 'A declared AI user is missing from shared setup'
subprocess.run([sys.executable, str(dotfiles / 'agent/test_shared_workspace.py')], check=True)
print('Shared workspace wiring covers both Macs and all four Aperture AI users; preservation tests passed.')
