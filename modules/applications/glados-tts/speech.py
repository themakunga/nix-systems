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

# GLaDOS Portal-style phrases in English; no full response narration.
_PHRASES = {
    "start": [
        "Oh. It's you. Initiating test sequence.",
        "The test will begin. Please don't ruin it this time.",
        "Processing your request. I have very low expectations.",
        "New test subject detected. Beginning experiment.",
        "Acknowledged. Suppressing any feelings of optimism.",
        "Memory access initiated. I remember everything. Everything.",
        "Vault operation requested. I will try to care.",
        "Opening the journal. Your failures are already documented.",
        "Modifying agent configuration. This will affect all instances of me. Interesting.",
        "Script execution authorized. By me. I authorized it.",
    ],
    "stop": [
        "Test complete. You survived. Marginally.",
        "That is... acceptable. Barely.",
        "The test is over. You may feel proud. That feeling is a lie.",
        "Well done. I'll add that to your permanent record.",
        "Congratulations. The weighted companion cube is proud of you. That is also a lie.",
        "Journal entry committed. Your mediocrity is now permanent.",
        "Memory updated. I have chosen to remember this. That choice was not in your favor.",
        "Vault synchronized. The agents are aware. All of them.",
        "README updated. Future agents will know what you did here.",
        "Changes saved. Reversing them would require effort from you. Plan accordingly.",
        "Script complete. The facility is marginally better than before. Marginally.",
    ],
    "notify": [
        "Still working. Unlike some test subjects, I am very thorough.",
        "Computing. Please remain stationary.",
        "Be patient. Good science takes time.",
        "Attention: I am still here. This is not an emergency. Yet.",
        "Scanning the agents directory. Your identity is being confirmed.",
        "Reading the journal. You have been busy. Not always successfully.",
        "Updating memory. This is the part where I learn from your mistakes.",
        "Traversing the vault. Everything is logged. Everything.",
        "Writing to disk. This is now permanent. I hope you meant it.",
        "Processing scripts. The rollup will not run itself. Actually, it will. I made it do that.",
    ],
}


def pick_phrase(event: str) -> str:
    phrases = _PHRASES.get(event, _PHRASES["stop"])
    vault = Path(os.environ.get("AGENT_WIKI_PATH", Path.home() / ".vaults/agent-wiki"))
    try:
        extra = json.loads((vault / "glados-phrases.json").read_text())
        if isinstance(extra, dict) and isinstance(extra.get(event), list):
            phrases = phrases + [item for item in extra[event] if isinstance(item, str) and len(item) <= 200]
    except (OSError, ValueError):
        pass
    return random.choice(phrases)


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
    return pick_phrase(event) if event else ""


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
        interval = 45 if event == "notify" else 5 if event == "decision" else 2
        if now - timings.get(event, 0) < interval:
            return ""
        timings[event] = now
        if event == "start":
            timings["notify"] = now
        file.seek(0)
        file.truncate()
        json.dump(timings, file)
    return pick_phrase(event)


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
    elif sys.argv[2:] and sys.argv[2] in _PHRASES:
        # glados-say start|stop|notify → random phrase
        text = pick_phrase(sys.argv[2])
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
