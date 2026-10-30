"""Run: python3 scripts/check-shared-plain.py (fixtures only; no real secrets copied)."""

import json
import os
from pathlib import Path
import re
import stat
import subprocess
import tempfile


config = json.loads(subprocess.check_output(
    ["nix", "eval", "--json", "--no-write-lock-file", ".#darwinConfigurations.kanagawa",
     "--apply", "host: { script = host.config.system.activationScripts.postActivation.text; path = host.pkgs.lib.makeBinPath [host.pkgs.coreutils]; }"],
    cwd=Path(__file__).resolve().parent.parent, text=True,
))
block = re.search(
    r'^_dest_parent="\$\(dirname "[^"]+/nchat/key\.conf"\)"\n.*?^chmod [^\n]+$',
    config["script"], re.MULTILINE | re.DOTALL,
)
assert block, "Missing nchat copy script"
copy = re.search(r'^.*?cp [^\n]*?"([^"]+)" "([^"]+)"$', block[0], re.MULTILINE)
assert copy, "Missing copy command"

for case in ("dangling", "missing", "file", "linked-file", "hardlink"):
    with tempfile.TemporaryDirectory(prefix="shared plain ") as directory:
        root = Path(directory)
        source = root / "source/key.conf"
        source.parent.mkdir()
        source.write_text("fixture configuration\n")
        target = root / ".config/nchat/key.conf"
        target.parent.mkdir(parents=True)
        other = root / "unrelated.conf"
        other.write_text("keep me\n")
        if case == "dangling":
            target.symlink_to("../../.dotfiles/.config/nchat/key.conf")
        elif case == "file":
            target.write_text("old configuration\n")
        elif case == "linked-file":
            target.symlink_to(other)
        elif case == "hardlink":
            target.hardlink_to(other)
        script = block[0].replace(copy[1], str(source)).replace(copy[2], str(target))
        script = re.sub(r'^chown \S+', f"chown {os.getuid()}:{os.getgid()}", script, flags=re.MULTILINE)
        for _ in range(2):
            result = subprocess.run(
                ["bash", "-e", "-c", script],
                env={"PATH": config["path"] + os.pathsep + os.defpath},
                text=True, capture_output=True,
            )
            assert result.returncode == 0, f"{case}: {result.stderr}"
            assert not target.is_symlink(), case
            assert target.read_text() == source.read_text(), case
            assert stat.S_IMODE(target.stat().st_mode) == 0o600, case
            assert target.stat().st_uid == os.getuid(), case
            assert other.read_text() == "keep me\n", case
        print(f"{case}: OK")
