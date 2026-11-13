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
    for target, overrides, address, builder in [
        ("switch-motherbase", [], "motherbase.local", "root@motherbase.local"),
        ("switch-motherbase", ["TARGET_IP=motherbase.local"], "motherbase.local", "root@motherbase.local"),
        ("switch-motherbase", ["TARGET_IP=192.0.2.10"], "192.0.2.10", "root@192.0.2.10"),
        ("switch-motherbase", ["TARGET_IP=192.168.1.100"], "192.168.1.100", "root@192.168.1.100"),
        ("deploy-motherbase", [], "motherbase.local", "root@motherbase.local"),
        ("switch-motherbase", ["TARGET_IP=192.0.2.10", "BUILD_HOST=builder@example.test"], "192.0.2.10", "builder@example.test"),
        ("deploy-motherbase", ["TARGET_IP=192.0.2.11"], "192.0.2.11", "root@192.0.2.11"),
    ]:
        log.unlink(missing_ok=True)
        result = subprocess.run(
            ["make", "-f", str(ROOT / "Makefile"), target, *overrides],
            cwd=directory, env=environment, text=True, capture_output=True,
        )
        assert result.returncode == 0, result.stdout + result.stderr
        assert log.read_text().splitlines() == [
            "run", "nixpkgs#nixos-rebuild", "--", "switch", "--flake", ".#motherbase",
            "--target-host", "root@" + address, "--build-host", builder, "--fast",
        ]
    (directory / "nix").write_text("#!/bin/sh\nexit 42\n")
    failed = subprocess.run(
        ["make", "-f", str(ROOT / "Makefile"), "switch-motherbase"],
        cwd=directory, env=environment, text=True, capture_output=True,
    )
    assert failed.returncode != 0, "A failed rebuild must fail Make"

print("Motherbase remote switch checks passed: address, builder, alias, no staging/local sudo and failure propagation.")
