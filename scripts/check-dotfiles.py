#!/usr/bin/env python3
"""Check every host against a local public-dotfiles checkout, without activation.

Usage: python3 scripts/check-dotfiles.py ~/.public-dotfiles
"""

import argparse
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("dotfiles", type=Path)
args = parser.parse_args()
dotfiles = args.dotfiles.expanduser().resolve()
if not dotfiles.is_dir():
    parser.error(f"Not a directory: {dotfiles}")

repo = Path(__file__).resolve().parent.parent
failed = False
for family in ("darwinConfigurations", "nixosConfigurations"):
    result = subprocess.run(
        [
            "nix", "eval", f".#{family}", "--json", "--no-write-lock-file",
            "--apply",
            "builtins.mapAttrs (_: host: {"
            " enabled = host.config.my.dotfiles.enable or false;"
            " packages = host.config.my.dotfiles.packages or [];"
            " warnings = host.config.warnings; })",
        ],
        cwd=repo, text=True, capture_output=True,
    )
    if result.returncode:
        print(result.stderr)
        failed = True
        continue
    for host, config in json.loads(result.stdout).items():
        missing = sorted({
            package["name"] for package in config["packages"]
            if config["enabled"] and not (dotfiles / package["name"]).is_dir()
        })
        for name in missing:
            print(f"{host}: missing dotfiles package {name}")
        for warning in config["warnings"]:
            print(f"{host}: {warning}")
        if missing or config["warnings"]:
            failed = True
        else:
            print(f"{host}: OK")

raise SystemExit(1 if failed else 0)
