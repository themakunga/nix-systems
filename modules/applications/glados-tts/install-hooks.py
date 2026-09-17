"""Merge the shared Stop hook without replacing other agent settings."""

import json
from pathlib import Path
import shutil
import sys
import tempfile
import os


COMMAND = '"$HOME/.local/bin/glados-hook"'


def install(home, bin_dir):
    # Validate both files before changing either; malformed settings are never overwritten.
    configs = []
    for name in (".codex/hooks.json", ".claude/settings.json"):
        path = (home / name).resolve()
        data = json.loads(path.read_text()) if path.exists() else {}
        groups = data.setdefault("hooks", {}).setdefault("Stop", [])
        if not any(
            hook.get("command") == COMMAND
            for group in groups
            for hook in group.get("hooks", [])
        ):
            groups.append(
                {"hooks": [{"type": "command", "command": COMMAND, "async": True}]}
            )
        configs.append((path, json.dumps(data, indent=2, ensure_ascii=False) + "\n"))
    local_bin = home / ".local/bin"
    local_bin.mkdir(parents=True, exist_ok=True)
    for name in ("glados-hook", "glados-say"):
        link = local_bin / name
        target = bin_dir / name
        if not target.is_file():
            raise FileNotFoundError(target)
        if link.exists() and not link.is_symlink():
            raise FileExistsError(f"Refusing to replace {link}")
        link.unlink(missing_ok=True)
        link.symlink_to(target)
    for path, content in configs:
        if path.exists() and path.read_text() == content:
            continue
        path.parent.mkdir(parents=True, exist_ok=True)
        if (
            path.exists()
            and not path.with_suffix(path.suffix + ".before-glados").exists()
        ):
            shutil.copy2(path, path.with_suffix(path.suffix + ".before-glados"))
        with tempfile.NamedTemporaryFile(
            mode="w", dir=path.parent, delete=False
        ) as tmp:
            tmp.write(content)
        os.replace(tmp.name, path)


if __name__ == "__main__":
    install(Path.home(), Path(sys.argv[1]).resolve())
