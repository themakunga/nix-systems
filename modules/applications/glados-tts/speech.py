"""Local speech; shared Stop hook for Codex and Claude Code."""

import fcntl
import hashlib
import json
import os
from pathlib import Path
import random
import re
import subprocess
import sys
import tempfile
import time

_EVENTS = ("start", "stop", "notify")


def _project_context(cwd: str = "") -> str:
    """Return the lowercase project directory name for phrase selection."""
    path = cwd or os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    return Path(path).name.lower() if path else ""


def pick_phrase(event: str, context: str = "") -> str:
    # ponytail: first existing root wins; amgmt replaced the old agent-wiki vault.
    roots = [os.environ.get("AGENT_WIKI_PATH"), Path.home() / "Projects/personal/amgmt", Path.home() / ".vaults/agent-wiki"]
    vault = next((Path(r) for r in roots if r and (Path(r) / "scripts").is_dir()), Path(roots[1]))
    pool: list[str] = []

    # Base phrase pool (first file that loads wins)
    for name in ("glados-phrases.json", "glados-phrases-base.json"):
        try:
            catalog = json.loads((vault / "scripts" / name).read_text())
        except (OSError, ValueError):
            continue
        if not isinstance(catalog, dict):
            continue
        phrases = catalog.get(event, catalog.get("stop"))
        if isinstance(phrases, list):
            pool = [p for p in phrases if isinstance(p, str) and len(p) <= 200]
            break

    # Context-specific phrases: weighted 3:1 over base
    if context:
        try:
            ctx = json.loads((vault / "scripts" / "glados-phrases-context.json").read_text())
            for pattern, buckets in ctx.get("patterns", {}).items():
                if pattern in context:
                    ctx_phrases = [p for p in buckets.get(event, []) if isinstance(p, str) and len(p) <= 200]
                    pool += ctx_phrases * 3
                    break
        except (OSError, ValueError):
            pass

    return random.choice(pool) if pool else ""


def spoken_text(text):
    if not isinstance(text, str):
        return ""
    # ponytail: basic Markdown cleanup; use a parser if richer markup needs narration.
    text = re.sub(r"(?ms)^\s*(`{3,}|~{3,})[^\n]*\n.*?(?:^\s*\1\s*$|\Z)", "", text)
    text = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"https?://\S+", "", text)
    text = re.sub(r"(?m)^\s*(?:#{1,6}\s+|[-*>]\s+|\d+[.)]\s+)", "", text)
    return " ".join(text.translate(str.maketrans("", "", "`*#")).split())


def event_for(payload):
    if not isinstance(payload, dict) or payload.get("stop_hook_active"):
        return None
    event = payload.get("hook_event_name")
    if event == "UserPromptSubmit":
        return "start"
    if event == "Stop":
        return "stop"
    if event == "PermissionRequest":
        return "decision"
    if event == "PreToolUse":
        tool = str(payload.get("tool_name") or "").lower()
        if any(name in tool for name in ("askuserquestion", "request_user_input", "elicitation")):
            return "decision"
        return "notify"
    if event == "Notification" and payload.get("notification_type") in ("permission_prompt", "elicitation_dialog"):
        return "decision"
    return None


def response(payload):
    event = event_for(payload)
    if not event:
        return ""
    return pick_phrase(event, _project_context(payload.get("cwd", "")))


def hook_text(payload):
    event = event_for(payload)
    if not event:
        return ""
    state = Path.home() / ".config/glados-tts"
    state.mkdir(parents=True, exist_ok=True)
    session = hashlib.sha256(str(payload.get("session_id", "default")).encode()).hexdigest()
    with (state / f"events-{session}.json").open("a+") as file:
        fcntl.flock(file, fcntl.LOCK_EX)
        file.seek(0)
        saved = file.read()
        timings = json.loads(saved) if saved else {}
        now = time.time()
        interval = 90 if event == "notify" else 15 if event == "decision" else 5
        if now - timings.get(event, 0) < interval:
            return ""
        timings[event] = now
        if event == "start":
            timings["notify"] = now
        file.seek(0)
        file.truncate()
        json.dump(timings, file)
    return pick_phrase(event, _project_context(payload.get("cwd", "")))


def render(text, wav):
    subprocess.run(
        [os.environ["GLADOS_PIPER"], "--model", os.environ["GLADOS_MODEL"], "--output_file", str(wav)],
        input=text, text=True, check=True, stdout=subprocess.DEVNULL, timeout=300,
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
        text = hook_text(json.load(sys.stdin))
    elif sys.argv[2:] and sys.argv[2] in _EVENTS:
        # glados-say start|stop|notify → random phrase
        text = pick_phrase(sys.argv[2], _project_context())
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
