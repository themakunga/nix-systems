"""Check quiet audio activation with mocked devices; never changes audio settings."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parent.parent
source = (root / 'modules/modules/device/audio.nix').read_text()
block = source[source.index('        configure_audio_device()'):source.index("      '';", source.index('        configure_audio_device()'))]
block = block.replace('${pkgs.switchaudio-osx}/bin/SwitchAudioSource', 'audio_mock')
for scenario in ('present', 'absent', 'list-error', 'select-error'):
    mock = '''
audio_mock() {
  if [ "$1" = -a ]; then
    case "$SCENARIO" in
      list-error) echo 'device enumeration failed'; return 1;;
      absent) echo 'Built-in audio';;
      *) printf '%s\\n' 'HyperX QuadCast' 'head radio';;
    esac
  elif [ "$SCENARIO" = select-error ]; then
    echo 'device selection failed'; return 1
  else
    echo 'verbose device selection output'
  fi
}
'''
    result = subprocess.run(['/bin/bash', '-eu', '-c', mock + block],
                            env={'SCENARIO': scenario}, text=True, capture_output=True)
    assert result.returncode == 0, result.stderr
    assert 'verbose' not in result.stdout
    if scenario == 'present':
        assert result.stdout.splitlines() == ['  OK: HyperX QuadCast', '  OK: head radio']
        assert not result.stderr
    elif scenario == 'absent':
        assert not result.stdout and not result.stderr
    else:
        assert 'failed' in result.stderr and not result.stdout
makefile = (root / 'Makefile').read_text()
assert 'sudo nix-env -p /nix/var/nix/profiles/system' not in makefile
assert 'sudo ./result/sw/bin/darwin-rebuild activate' not in makefile
assert makefile.count('sudo -H nix-env -p /nix/var/nix/profiles/system') == 4
assert makefile.count('sudo -H ./result/sw/bin/darwin-rebuild activate') == 4
print('OK: absent audio is silent, success is brief, failures remain visible, sudo uses root HOME.')
