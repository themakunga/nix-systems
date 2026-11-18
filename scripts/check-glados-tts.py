"""Check the playback-only engine without audio or real user settings."""

import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile
from unittest.mock import patch

source = Path(__file__).resolve().parents[1] / "modules/applications/glados-tts/speech.py"
spec = importlib.util.spec_from_file_location("speech", source)
speech = importlib.util.module_from_spec(spec)
spec.loader.exec_module(speech)
with tempfile.TemporaryDirectory() as directory:
    home = Path(directory)
    with (
        patch.object(Path, "home", return_value=home),
        patch.object(speech.subprocess, "run") as run,
    ):
        with patch.dict(
            speech.os.environ,
            {"GLADOS_PIPER": "piper", "GLADOS_MODEL": "model", "GLADOS_PLAYER": "afplay"},
        ):
            speech.speak("$(touch /tmp/should-not-exist)")
        assert run.call_count == 2
        assert run.call_args_list[0].kwargs["input"] == "$(touch /tmp/should-not-exist)"
        assert not Path(run.call_args.args[0][-1]).exists()
        (home / ".config/glados-tts/muted").touch()
        speech.speak("Muted")
        assert run.call_count == 2
for event in ("hook", "say"):
    result = subprocess.run(
        [sys.executable, str(source), event, "stop"], capture_output=True, text=True
    )
    assert not result.stdout and "GLaDOS speech:" in result.stderr
print("GLaDOS: playback invocation, mute, cleanup and retired automatic selectors passed.")
