"""Check the built wrapper and managed discovery links without the legacy vault path."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


root = Path(__file__).resolve().parents[1]
module = (root / "modules/modules/common/agent-wiki.nix").read_text()
loop = "for agent_home in " + module.split("for agent_home in ", 1)[1].split(
    "          for agent in codex claude-code hermes;", 1
)[0]
wrapper = Path(sys.argv[1]).resolve(strict=True)

with tempfile.TemporaryDirectory(prefix="glados paths ") as directory:
    home = Path(directory)
    vault = home / ".vaults/amgmt"
    target = vault / "skills/agent-glados"
    script = target / "scripts/glados.py"
    script.parent.mkdir(parents=True)
    script.write_text("import json, sys; print(json.dumps(sys.argv))\n")
    legacy = vault / "skills/glados"
    foreign = home / "unrelated skill"
    foreign.mkdir()
    for runtime in (".agents", ".claude", ".hermes", ".gemini", ".openclaw"):
        (home / runtime / "skills").mkdir(parents=True)
    managed = home / ".agents/skills/glados"
    managed.symlink_to(legacy)
    (home / ".hermes/skills/glados").symlink_to(foreign)
    (home / ".gemini/skills/glados").symlink_to(home / "missing unrelated skill")
    (home / ".openclaw/skills/glados").mkdir()
    environment = dict(os.environ, HOME=str(home), USER_HOME=str(home), WIKI_DIR=str(vault))
    for legacy_exists in (False, True):
        managed.unlink()
        managed.symlink_to(legacy)
        if legacy_exists:
            legacy.symlink_to(target)
        for _ in range(2):
            subprocess.run(["bash", "-c", 'run_as_user() { "$@"; }\n' + loop],
                           env=environment, check=True)
            assert managed.readlink() == target
            assert (home / ".claude/skills/glados").readlink() == target
            assert (home / ".hermes/skills/glados").readlink() == foreign
            assert (home / ".gemini/skills/glados").readlink() == home / "missing unrelated skill"
            assert not (home / ".openclaw/skills/glados").is_symlink()
            assert not (home / ".zeroclaw").exists()
        if legacy_exists:
            legacy.unlink()
    result = subprocess.run([str(wrapper), "--agent", "codex", "due"], env=environment,
                            capture_output=True, text=True, check=True)
    assert json.loads(result.stdout) == [str(script), "--vault", str(vault),
                                        "--agent", "codex", "due"]
    script.unlink()
    missing = subprocess.run([str(wrapper), "--agent", "codex", "due"], env=environment,
                             capture_output=True, text=True)
    assert missing.returncode == 1 and "GLaDOS skill is unavailable" in missing.stderr

print("GLaDOS: renamed wrapper path, link migration, idempotence and unrelated skills passed.")
