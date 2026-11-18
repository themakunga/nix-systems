"""Run: python3 scripts/check-vault-paths.py (no system activation)."""

import json
from pathlib import Path
import re
import subprocess
import tempfile


repo = Path(__file__).resolve().parent.parent
darwin = json.loads(subprocess.check_output(
    ["nix", "eval", "--json", "--no-write-lock-file", ".#darwinConfigurations",
     "--apply", "builtins.mapAttrs (_: host: host.config.system.activationScripts.postActivation.text)"],
    cwd=repo, text=True,
))
linux = json.loads(subprocess.check_output(
    ["nix", "eval", "--json", "--no-write-lock-file", ".#nixosConfigurations",
     "--apply", "builtins.mapAttrs (_: host: builtins.mapAttrs (_: script: if builtins.isAttrs script then script.text else script) host.config.system.activationScripts)"],
    cwd=repo, text=True,
))
for host, scripts in {**{h: {"postActivation": s} for h, s in darwin.items()}, **linux}.items():
    for script in scripts.values():
        for path in re.findall(r'^\s*(?:WIKI_DIR|WIKI_SOUL|HOOK)="([^"]+)"', script, re.MULTILINE):
            assert "/.vaults/" in path, f"{host}: {path}"
print("All declared vault paths are under ~/.vaults")

migration = re.search(
    r'^if \[ ! -e "\$WIKI_DIR" \].*?^fi$',
    darwin["kanagawa"], re.MULTILINE | re.DOTALL,
)
assert migration, "Missing vault migration"
for occupied in (False, True):
    with tempfile.TemporaryDirectory(prefix="vault migration ") as directory:
        root = Path(directory)
        legacy = root / "Projects/personal/amgmt"
        target = root / ".vaults/amgmt"
        (legacy / ".git").mkdir(parents=True)
        (legacy / "notes.md").write_text("keep me")
        target.parent.mkdir()
        if occupied:
            target.mkdir()
            (target / "notes.md").write_text("existing vault")
        script = 'run_as_user() { "$@"; }\n' + migration[0]
        for _ in range(2):
            subprocess.run(
                ["bash", "-e", "-c", script], check=True,
                env={"WIKI_DIR": str(target), "LEGACY_WIKI_DIR": str(legacy),
                     "PATH": "/usr/bin:/bin"},
            )
        if occupied:
            assert not legacy.is_symlink()
            assert (legacy / "notes.md").read_text() == "keep me"
            assert (target / "notes.md").read_text() == "existing vault"
        else:
            assert legacy.is_symlink() and legacy.resolve() == target.resolve()
            assert (target / "notes.md").read_text() == "keep me"
print("Vault migration preserves notes, existing destinations and repeated runs")
