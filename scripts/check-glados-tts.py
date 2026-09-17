"""Run with python3 scripts/check-glados-tts.py; no audio or real settings touched."""

import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
from unittest.mock import patch

source = Path(__file__).resolve().parents[1] / "modules/applications/glados-tts"


def load(name):
    spec = importlib.util.spec_from_file_location(name, source / f"{name}.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


speech = load("speech")
installer = load("install-hooks")
message = "# Done\n**Fixed** [the bug](https://example.com).\n```sh\nrm -rf /\n```\nTests passed."
assert (
    speech.response({"hook_event_name": "Stop", "last_assistant_message": message})
    == "Done Fixed the bug. Tests passed."
)
assert (
    speech.response(
        {"hook_event_name": "SubagentStop", "last_assistant_message": message}
    )
    == ""
)
for payload in (
    None,
    [],
    {},
    {"hook_event_name": "Stop", "last_assistant_message": None},
):
    assert speech.response(payload) == ""
assert speech.spoken_text("```python\nunfinished code") == ""
assert (
    speech.spoken_text("Hola, Nicolás. ¡Prueba lista!")
    == "Hola, Nicolás. ¡Prueba lista!"
)

with tempfile.TemporaryDirectory() as directory:
    home = Path(directory).resolve()
    bin_dir = home / "bin"
    bin_dir.mkdir()
    for name in ("glados-hook", "glados-say"):
        (bin_dir / name).touch()
    settings = home / ".claude/settings.json"
    settings.parent.mkdir()
    original = {
        "permissions": {"allow": ["Read"]},
        "hooks": {
            "Stop": [{"hooks": [{"type": "command", "command": "existing-hook"}]}]
        },
    }
    settings.write_text(json.dumps(original))
    installer.install(home, bin_dir)
    first = settings.read_text()
    installer.install(home, bin_dir)
    assert settings.read_text() == first
    data = json.loads(first)
    assert data["permissions"] == original["permissions"]
    assert data["hooks"]["Stop"][0] == original["hooks"]["Stop"][0]
    assert len(data["hooks"]["Stop"]) == 2
    assert (
        json.loads(settings.with_suffix(".json.before-glados").read_text()) == original
    )
    assert (home / ".local/bin/glados-hook").resolve() == bin_dir / "glados-hook"
    codex = home / ".codex/hooks.json"
    codex.write_text("invalid JSON")
    try:
        installer.install(home, bin_dir)
        raise AssertionError("Invalid settings were accepted")
    except json.JSONDecodeError:
        pass
    assert settings.read_text() == first
    assert codex.read_text() == "invalid JSON"
    with (
        patch.object(Path, "home", return_value=home),
        patch.object(speech.subprocess, "run") as run,
    ):
        with patch.dict(
            speech.os.environ,
            {
                "GLADOS_PIPER": "piper",
                "GLADOS_MODEL": "model",
                "GLADOS_PLAYER": "afplay",
            },
        ):
            speech.speak("$(touch /tmp/should-not-exist)")
        assert run.call_count == 2
        assert run.call_args_list[0].args[0][:4] == [
            "piper",
            "--model",
            "model",
            "--output_file",
        ]
        assert run.call_args_list[0].kwargs["input"] == "$(touch /tmp/should-not-exist)"
        assert not Path(
            run.call_args.args[0][-1]
        ).exists()  # WAV temporary directory cleaned.
        (home / ".config/glados-tts/muted").touch()
        speech.speak("Muted")
        assert run.call_count == 2

bad = subprocess.run(
    [sys.executable, str(source / "speech.py"), "hook"],
    input="not JSON",
    text=True,
    capture_output=True,
)
assert bad.returncode == 0 and not bad.stdout and "GLaDOS speech:" in bad.stderr
print(
    "GLaDOS: hook payloads, Markdown, safe speech invocation, mute, cleanup and settings merge passed."
)
