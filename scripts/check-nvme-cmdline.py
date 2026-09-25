"""Run from the repository root: python3 scripts/check-nvme-cmdline.py.

Exercise the evaluated boot script against temporary firmware, never the host.
Requires GNU sed on PATH (as used by NixOS), including when run on macOS.
"""

import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


script = json.loads(subprocess.check_output([
    "nix", "eval", "--json", "--no-write-lock-file",
    ".#nixosConfigurations.aperture-science.config.system.activationScripts.nvme-direct-boot.text",
]))
# The evaluated script uses ARM64 store executables; use native tools for this check.
script = re.sub(r"/nix/store/[^/]+/bin/(\w+)",
                lambda match: shutil.which(match[1]) or match[1], script)
with tempfile.TemporaryDirectory(prefix="nvme-cmdline-") as directory:
    root = Path(directory).resolve()
    firmware = root / "firmware"
    firmware.mkdir()
    (firmware / "config.txt").write_text("kernel=nixos-kernel.img\n")
    for name in ["kernel", "initrd", "init"]:
        (root / name).write_text(name)
    activate = root / "activate"
    activate.write_text("mountpoint() { return 0; }\n" +
                        script.replace("/boot/firmware", str(firmware)))
    # Changing the generated parameters must change cmdline without editing the script.
    for extra in ["loglevel=3", "loglevel=7 console=tty1"]:
        parameters = f"pcie_aspm=off rootwait root=fstab {extra}"
        (root / "kernel-params").write_text(parameters)
        subprocess.run(["bash", "-e", str(activate)], check=True)
        cmdline = (firmware / "cmdline.txt").read_text()
        assert cmdline == f"init={root}/init {parameters}\n", cmdline
        assert [p for p in cmdline.split() if p.startswith("root=")] == ["root=fstab"]
        assert (firmware / "nixos-kernel.img").read_text() == "kernel"
        assert (firmware / "nixos-initrd.img").read_text() == "initrd"
        assert (firmware / "config.txt").read_text().count("initramfs ") == 1
print("NVMe cmdline OK: generated parameters preserved, one root=fstab")
