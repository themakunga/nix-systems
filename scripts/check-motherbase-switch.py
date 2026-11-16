#!/usr/bin/env python3
"""Exercise the real Make targets with stub commands; never switches a system."""

import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]

with tempfile.TemporaryDirectory(prefix="motherbase-switch-") as temporary:
    directory = Path(temporary)
    log = directory / "nix-arguments"
    for name, script in {
        "nix": '#!/bin/sh\nprintf "%s\\n" "$@" > "$SWITCH_TEST_LOG"\n',
        "git": '#!/bin/sh\necho "Unexpected git mutation" >&2\nexit 91\n',
        "sudo": '#!/bin/sh\necho "Unexpected local sudo" >&2\nexit 92\n',
    }.items():
        command = directory / name
        command.write_text(script)
        command.chmod(0o755)
    environment = {
        **os.environ,
        "PATH": str(directory) + os.pathsep + os.environ["PATH"],
        "SWITCH_TEST_LOG": str(log),
    }
    cases = [
        ("switch-motherbase", [], "motherbase.local", "root@motherbase.local"),
        ("switch-motherbase", ["TARGET_IP=motherbase.local"], "motherbase.local", "root@motherbase.local"),
        ("switch-motherbase", ["TARGET_IP=192.0.2.10"], "192.0.2.10", "root@192.0.2.10"),
        ("switch-motherbase", ["TARGET_IP=192.168.1.100"], "192.168.1.100", "root@192.168.1.100"),
        ("deploy-motherbase", [], "motherbase.local", "root@motherbase.local"),
        ("switch-motherbase", ["TARGET_IP=192.0.2.10", "BUILD_HOST=builder@example.test"], "192.0.2.10", "builder@example.test"),
        ("deploy-motherbase", ["TARGET_IP=192.0.2.11"], "192.0.2.11", "root@192.0.2.11"),
    ]
    for target, hostname in [("switch-msf", "msf"), ("switch-aperture", "aperture-science")]:
        cases.extend([
            (target, [], hostname + ".local", "root@" + hostname + ".local"),
            (target, ["TARGET_IP=" + hostname + ".local"], hostname + ".local", "root@" + hostname + ".local"),
            (target, ["TARGET_IP=192.0.2.10"], "192.0.2.10", "root@192.0.2.10"),
            (target, ["TARGET_IP=192.168.1.100"], "192.168.1.100", "root@192.168.1.100"),
            (target, ["TARGET_IP=192.0.2.10", "BUILD_HOST=builder@example.test"], "192.0.2.10", "builder@example.test"),
        ])
    cases.extend([
        ("switch-aperture", ["APERTURE_IP=192.0.2.20"], "192.0.2.20", "root@192.0.2.20"),
        ("switch-aperture", ["APERTURE_IP=192.0.2.20", "TARGET_IP=192.0.2.21"], "192.0.2.21", "root@192.0.2.21"),
    ])
    for target, overrides, address, builder in cases:
        log.unlink(missing_ok=True)
        result = subprocess.run(
            ["make", "-f", str(ROOT / "Makefile"), target, *overrides],
            cwd=directory, env=environment, text=True, capture_output=True,
        )
        assert result.returncode == 0, result.stdout + result.stderr
        hostname = {"switch-msf": "msf", "switch-aperture": "aperture-science"}.get(target, "motherbase")
        assert log.read_text().splitlines() == [
            "run", "nixpkgs#nixos-rebuild", "--", "switch", "--flake", ".#" + hostname,
            "--target-host", "root@" + address, "--build-host", builder, "--fast",
        ]
    (directory / "nix").write_text("#!/bin/sh\nexit 42\n")
    for target in ["switch-motherbase", "switch-msf", "switch-aperture"]:
        failed = subprocess.run(
            ["make", "-f", str(ROOT / "Makefile"), target],
            cwd=directory, env=environment, text=True, capture_output=True,
        )
        assert failed.returncode != 0, "A failed rebuild must fail Make"

print("Remote switch checks passed for motherbase, msf and aperture-science: address, builder, alias, no staging/local sudo and failure propagation.")
