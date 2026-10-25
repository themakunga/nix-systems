#!/usr/bin/env python3
"""Update only token-counter to GitHub's latest non-prerelease release."""
import json
from pathlib import Path
import re
import subprocess
import sys


def stable_tag(release):
    tag = release.get("tag_name", "")
    if release.get("draft") or release.get("prerelease") or not re.fullmatch(r"v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)", tag):
        raise ValueError("Expected a published stable vX.Y.Z release")
    return tag


if __name__ == "__main__":
    if sys.argv[1:] == ["--self-test"]:
        assert stable_tag({"tag_name": "v0.3.1"}) == "v0.3.1"
        for release in ({"tag_name": "nightly"}, {"tag_name": "v0.4.0-rc.1"}, {"tag_name": "v0.4.0", "draft": True}, {"tag_name": "v0.4.0", "prerelease": True}):
            try:
                stable_tag(release)
            except ValueError:
                continue
            raise AssertionError(release)
        print("Stable release selection: OK")
    else:
        root = Path(__file__).resolve().parent.parent
        result = subprocess.run(["gh", "api", "repos/themakunga/token-counter/releases/latest"], check=True, capture_output=True, text=True, timeout=30)
        tag = stable_tag(json.loads(result.stdout))
        flake = root / "flake.nix"
        updated, count = re.subn(r'github:TheMakunga/token-counter/[^"\s]+', f"github:TheMakunga/token-counter/{tag}", flake.read_text())
        if count != 1:
            raise ValueError("Expected exactly one token-counter input")
        flake.write_text(updated)
        subprocess.run(["nix", "flake", "update", "token-counter"], cwd=root, check=True, timeout=300)
        print(f"token-counter input updated to {tag}")
