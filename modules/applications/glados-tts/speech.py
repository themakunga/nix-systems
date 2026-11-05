"""Local speech; shared Stop hook for Codex and Claude Code."""

import fcntl
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

_EVENTS = ("start", "stop", "notify")


def spoken_text(text):
    if not isinstance(text, str):
        return ""
    # ponytail: basic Markdown cleanup; use a parser if richer markup needs narration.
    text = re.sub(r"(?ms)^\s*(`{3,}|~{3,})[^\n]*\n.*?(?:^\s*\1\s*$|\Z)", "", text)
    text = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"https?://\S+", "", text)
    text = re.sub(r"(?m)^\s*(?:#{1,6}\s+|[-*>]\s+|\d+[.)]\s+)", "", text)
    return " ".join(text.translate(str.maketrans("", "", "`*#")).split())


def render(text, wav):
    subprocess.run(
        [
            os.environ["GLADOS_PIPER"],
            "--model",
            os.environ["GLADOS_MODEL"],
            "--output_file",
            str(wav),
        ],
        input=text,
        text=True,
        check=True,
        stdout=subprocess.DEVNULL,
        timeout=300,
    )


def speak(text):
    state = Path.home() / ".config/glados-tts"
    if not text or (state / "muted").exists():
        return
    state.mkdir(parents=True, exist_ok=True)
    # ponytail: one playback queue per user; split by audio device if needed.
    with (state / "playback.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if (state / "muted").exists():
            return
        with tempfile.TemporaryDirectory(prefix="glados-") as directory:
            wav = str(Path(directory) / "speech.wav")
            render(text, wav)
            subprocess.run(
                [os.environ["GLADOS_PLAYER"], wav],
                check=True,
                stdout=subprocess.DEVNULL,
                timeout=1800,
            )


def main():
    mode = sys.argv[1]
    if mode == "say" and sys.argv[2:] in (["--mute"], ["--unmute"]):
        marker = Path.home() / ".config/glados-tts/muted"
        marker.parent.mkdir(parents=True, exist_ok=True)
        if sys.argv[2] == "--mute":
            marker.touch()
        else:
            marker.unlink(missing_ok=True)
        return
    if mode == "render":
        render(spoken_text(Path(sys.argv[2]).read_text()), sys.argv[3])
        return
    if mode == "hook":
        raise ValueError("Legacy hook disabled; use the standalone glados skill")
    elif sys.argv[2:] and sys.argv[2] in _EVENTS:
        # glados-say start|stop|notify → random phrase
        raise ValueError("Event selection moved to glados-agent")
    else:
        text = spoken_text(" ".join(sys.argv[2:]) if sys.argv[2:] else sys.stdin.read())
    speak(text)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        print(f"GLaDOS speech: {error}", file=sys.stderr)
        # Speech failures must never block/continue an agent's turn.
        sys.exit(0 if sys.argv[1:2] == ["hook"] else 1)
