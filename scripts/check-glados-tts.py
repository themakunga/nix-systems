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
assert speech.response({"hook_event_name": "Stop"}) in speech._PHRASES["stop"]
for payload in (None, []):
    assert speech.response(payload) == ""
assert speech.response({"hook_event_name": "PreToolUse", "tool_name": "AskUserQuestion"}) in speech._PHRASES["decision"]
assert speech.response({"hook_event_name": "PreToolUse", "tool_name": "mcp__tools__request_user_input_async"}) in speech._PHRASES["decision"]
assert speech.response({"hook_event_name": "Notification", "notification_type": "idle_prompt"}) == ""
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
    for event in ("UserPromptSubmit", "PreToolUse", "PermissionRequest", "Stop"):
        assert sum(h.get("command") == installer.COMMAND for g in data["hooks"][event] for h in g["hooks"]) == 1
    with patch.object(Path, "home", return_value=home), patch.object(speech.time, "time", return_value=100):
        assert speech.hook_text({"hook_event_name": "UserPromptSubmit", "session_id": "s"})
        assert not speech.hook_text({"hook_event_name": "PreToolUse", "session_id": "s"})
        assert speech.hook_text({"hook_event_name": "PermissionRequest", "session_id": "s"})
        assert not speech.hook_text({"hook_event_name": "PermissionRequest", "session_id": "s"})
    with patch.object(Path, "home", return_value=home), patch.object(speech.time, "time", return_value=146):
        assert speech.hook_text({"hook_event_name": "PreToolUse", "session_id": "s"})
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
