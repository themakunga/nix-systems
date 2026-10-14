# GLaDOS para Codex y Claude Code

Activado para `kanagawa` y `outer-heaven` mediante `my.apps.glados-tts.enable`.
Piper genera la voz localmente con el modelo
[GLaDOS de DavesArmoury](https://huggingface.co/DavesArmoury/GLaDOS_TTS)
(CC BY 4.0, versión fijada en Nix). No requiere API ni envía las respuestas a
un servicio TTS. El modelo está entrenado en inglés y los avisos automáticos
se emiten en inglés. No cambia el idioma de las respuestas del agente.

## Uso

`darwin-rebuild switch` instala el motor y agrega un hook `Stop` a
`~/.codex/hooks.json` y `~/.claude/settings.json`, conservando los ajustes
existentes y una copia `.before-glados` de los archivos modificados.
Reinicia las sesiones de Codex y Claude Code después de instalar.

En Codex, abre `/hooks` y revisa/autoriza el comando
`"$HOME/.local/bin/glados-hook"`: los hooks nuevos no se ejecutan hasta que
los apruebas. Es una protección de Codex, descrita en su
[documentación oficial](https://developers.openai.com/codex/hooks).

Emite una frase breve al terminar cada turno, en segundo plano; no lee la
respuesta completa. Las respuestas de varias sesiones se reproducen una a la
vez. Los errores del audio no bloquean al agente.

Funciona con sesiones locales que ejecuten hooks. Claude Code comparte los hooks
entre [terminal y escritorio](https://code.claude.com/docs/en/desktop#shared-configuration).
Las sesiones remotas ejecutan el hook en el equipo remoto; no reproducen audio
en este Mac. Esto no configura el chat normal de Claude.

```sh
~/.local/bin/glados-say "The cake is a lie."
~/.local/bin/glados-say --mute
~/.local/bin/glados-say --unmute
```

Silenciar evita nuevas reproducciones y las que esperan en la cola; un audio
que ya empezó termina de reproducirse. Para desinstalar la integración, quita
el grupo que llama a `glados-hook` de ambos archivos y deshabilita la app en Nix.

## Validación

```sh
python3 scripts/check-glados-tts.py
```

Prueba los eventos, la limpieza del texto, el silencio, la invocación segura del
motor, la limpieza de temporales y la instalación idempotente sin perder ajustes.
