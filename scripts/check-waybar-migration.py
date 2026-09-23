"""Run: python3 scripts/check-waybar-migration.py"""

import json
from pathlib import Path
import subprocess
import tempfile


scripts = json.loads(
    subprocess.check_output(
        [
            "nix",
            "eval",
            "--json",
            "--no-write-lock-file",
            ".#nixosConfigurations.aperture-science.config.system.activationScripts",
        ]
    )
)
assert "waybar-stow-migration" in scripts["stowDotfiles"]["deps"]
assert "-waybar-style.css" not in scripts["hyprland-config-wheatley"]["text"]
with tempfile.TemporaryDirectory() as directory:
    home = Path(directory)
    waybar = home / ".config/waybar"
    waybar.mkdir(parents=True)
    config = waybar / "config"
    style = waybar / "style.css"
    config.symlink_to("/nix/store/old-waybar-config.json")
    style.symlink_to("/nix/store/old-waybar-style.css")
    script = scripts["waybar-stow-migration"]["text"].replace(
        "/opt/wheatley", directory
    )
    subprocess.run(["bash", "-e", "-c", script], check=True)
    assert not config.is_symlink() and not style.is_symlink()
    config.write_text("custom config")
    style.symlink_to("../../.public-dotfiles/waybar/style.css")
    subprocess.run(["bash", "-e", "-c", script], check=True)
    assert config.read_text() == "custom config"
    assert style.readlink() == Path("../../.public-dotfiles/waybar/style.css")
print("Waybar migration OK")
