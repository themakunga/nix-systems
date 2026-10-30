"""Run: python3 scripts/check-dotfiles-activation.py (no system activation)."""

from pathlib import Path
import re
import subprocess
import tempfile


activation = subprocess.check_output(
    [
        "nix", "eval", "--raw", "--no-write-lock-file",
        ".#darwinConfigurations.kanagawa.config.system.activationScripts.postActivation.text",
    ],
    cwd=Path(__file__).resolve().parent.parent,
    text=True,
)
package = re.search(
    r'^PKG_NAME="lazygit"\n.*?(?=^PKG_NAME=|^echo "=> Dotfiles)',
    activation, re.MULTILINE | re.DOTALL,
)
assert package, "Missing lazygit deployment script"

for case in ("dangling", "missing", "directory", "linked-directory", "file", "linked-file"):
    with tempfile.TemporaryDirectory(prefix="dotfiles activation ") as directory:
        home = Path(directory)
        dotfiles = home / ".public-dotfiles"
        source = dotfiles / "lazygit/config.yml"
        source.parent.mkdir(parents=True)
        source.write_text("gui: {}\n")
        target = home / ".config/lazygit"
        target.parent.mkdir()
        if case == "dangling":
            target.symlink_to("../.dotfiles/.config/lazygit")
        elif case == "directory":
            target.mkdir()
        elif case == "linked-directory":
            (home / "existing").mkdir()
            target.symlink_to(home / "existing")
        elif case == "file":
            target.write_text("keep me")
        elif case == "linked-file":
            (home / "existing").write_text("keep me")
            target.symlink_to(home / "existing")
        if target.is_dir():
            (target / "local.txt").write_text("keep me")
        script = 'run_as_user() { "$@"; }\n' + package[0]
        for _ in range(2):
            result = subprocess.run(
                ["bash", "-e", "-c", script],
                env={"USER_HOME": str(home), "DOTFILES_DIR": str(dotfiles),
                     "PATH": "/run/current-system/sw/bin:/usr/bin:/bin"},
                text=True, capture_output=True,
            )
            if case in ("file", "linked-file"):
                assert result.returncode != 0, case
                assert target.read_text() == "keep me", case
            else:
                assert result.returncode == 0, f"{case}: {result.stderr}"
                assert (target / "config.yml").resolve() == source.resolve(), case
                assert source.read_text() == "gui: {}\n", case
        if case in ("directory", "linked-directory"):
            assert (target / "local.txt").read_text() == "keep me", case
        if case.startswith("linked-"):
            assert target.readlink() == home / "existing", case
        print(f"{case}: OK")
