"""Local speech; shared Stop hook for Codex and Claude Code."""

import fcntl
import json
import os
from pathlib import Path
import random
import re
import subprocess
import sys
import tempfile

# GLaDOS Portal-style phrases — bilingual, no full response narration.
_PHRASES = {
    "start": [
        "Oh. It's you. Initiating test sequence.",
        "The test will begin. Please don't ruin it this time.",
        "Processing your request. I have very low expectations.",
        "Iniciando secuencia de prueba. Espero que no lo arruines.",
        "Bien. La prueba comienza. Intente no fallar esta vez.",
        "New test subject detected. Beginning experiment.",
        "Comenzando. Por favor no hagas nada estúpido.",
        "Acknowledged. Suppressing any feelings of optimism.",
    ],
    "stop": [
        "Test complete. You survived. Marginally.",
        "That is... acceptable. Barely.",
        "Prueba concluida. Sus resultados son tolerables.",
        "Misión cumplida. Para variar, no fue un desastre total.",
        "The test is over. You may feel proud. That feeling is a lie.",
        "La prueba ha terminado. Felicitaciones por no destruir nada.",
        "Well done. I'll add that to your permanent record.",
        "Completado. Anotaré esto junto a todos los otros intentos menos exitosos.",
        "Congratulations. The weighted companion cube is proud of you. That is also a lie.",
    ],
    "notify": [
        "Still working. Unlike some test subjects, I am very thorough.",
        "Computing. Please remain stationary.",
        "Procesando. No vaya a ningún lado.",
        "Be patient. Good science takes time.",
        "Calculando. Intente no aburrirse.",
        "Attention: I am still here. This is not an emergency. Yet.",
    ],
}


def pick_phrase(event: str) -> str:
    return random.choice(_PHRASES.get(event, _PHRASES["stop"]))


def spoken_text(text):
    if not isinstance(text, str):
        return ""
    # ponytail: basic Markdown cleanup; use a parser if richer markup needs narration.
    text = re.sub(r"(?ms)^\s*(`{3,}|~{3,})[^\n]*\n.*?(?:^\s*\1\s*$|\Z)", "", text)
    text = re.sub(r"!?\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"https?://\S+", "", text)
    text = re.sub(r"(?m)^\s*(?:#{1,6}\s+|[-*>]\s+|\d+[.)]\s+)", "", text)
    return " ".join(text.translate(str.maketrans("", "", "`*#")).split())


def response(payload):
    """Hook mode: say a random stop phrase instead of narrating the full response."""
    if not isinstance(payload, dict):
        return ""
    return pick_phrase("stop")


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
            subprocess.run(
                [
                    os.environ["GLADOS_PIPER"],
                    "--model",
                    os.environ["GLADOS_MODEL"],
                    "--output_file",
                    wav,
                ],
                input=text,
                text=True,
                check=True,
                stdout=subprocess.DEVNULL,
                timeout=300,
            )
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
    if mode == "hook":
        text = response(json.load(sys.stdin))
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
