# Avisos GLaDOS para Codex y Claude Code

Activado para `kanagawa` y `outer-heaven` mediante `my.apps.glados-tts.enable`.
Piper genera la voz localmente con el modelo
[GLaDOS de DavesArmoury](https://huggingface.co/DavesArmoury/GLaDOS_TTS)
(CC BY 4.0, versión fijada en Nix). No requiere API ni envía las respuestas a
un servicio TTS. El modelo está entrenado en inglés y los avisos automáticos
se emiten en inglés. No cambia el idioma de las respuestas del agente.

## Comportamiento

- `UserPromptSubmit`: frase breve al comenzar.
- `PreToolUse`: aviso de trabajo como máximo cada 45 segundos por sesión; no suena inmediatamente después del inicio.
- `Stop`: frase de finalización; nunca lee el contenido de la respuesta.
- `PermissionRequest` y herramientas de preguntas reconocidas: frase solicitando una decisión. Claude también utiliza `Notification` para solicitudes de permisos e información.

Las frases son casuales, sarcásticas y breves. Se descartan eventos no reconocidos, paradas de subagentes y continuaciones de Stop. Los hooks no aprueban ni rechazan operaciones. El audio se reproduce en segundo plano y sus errores no bloquean el agente. La cola de audio es compartida por usuario.

Las frases base están en `agent-wiki/scripts/glados-phrases-base.json`. El rollup del journal genera `agent-wiki/scripts/glados-phrases.json` con esas frases y las de temas recientes. `speech.py` lee el catálogo generado en cada aviso y usa el base si falta; actualizar frases no requiere `nix switch`.

Emite una frase breve al terminar cada turno, en segundo plano; no lee la
respuesta completa. Las respuestas de varias sesiones se reproducen una a la
vez. Los errores del audio no bloquean al agente.

`my.apps.glados-tts.enable` en Nix instala motor, modelo y comandos. La activación macOS combina los hooks con los ajustes existentes, conservando una copia `.before-glados`. No reemplaza otros hooks ni el `notify` de Codex.

Para aplicar sólo los hooks cuando los comandos ya están instalados:

```sh
python3 modules/applications/glados-tts/install-hooks.py /run/current-system/sw/bin
```

Reiniciar las sesiones para cargar los cambios. En Codex, abrir `/hooks` y revisar/confiar en los hooks que ejecutan `"$HOME/.local/bin/glados-hook"`; [Codex exige revisar la definición exacta](https://learn.chatgpt.com/docs/hooks#review-and-trust-hooks). No se modifica el registro de confianza automáticamente.

Funciona en terminal y aplicaciones locales que ejecuten hooks. No instrumenta cada cambio visual del indicador de pensamiento. Una pregunta que no genere evento de hook no produce un aviso automático. Los hooks de sesiones remotas reproducen audio en el host remoto.

```sh
glados-say start
glados-say notify
glados-say decision
glados-say stop
glados-say --mute
glados-say --unmute
```

## Hermes y Telegram

Hermes necesita un runtime y bot configurados. Usar la voz local mediante `tts.piper.voice` con la ruta absoluta del modelo, o un proveedor `tts.providers.glados` de tipo `command` que produzca audio. La conversión a Opus/OGG requiere ffmpeg. [Referencia TTS de Hermes](https://hermes-agent.nousresearch.com/docs/user-guide/features/tts).

En el chat del bot, `/voice tts` activa respuestas de audio para todos los mensajes y persiste entre reinicios; `/voice off` las desactiva. [Referencia de mensajes de voz](https://hermes-agent.nousresearch.com/docs/user-guide/features/voice-mode). Esta opción corresponde a respuestas conversacionales, no a los avisos cortos de los agentes de código.

## Validación

```sh
python3 scripts/check-glados-tts.py
```

Comprueba clasificación de eventos, supresión de contenido privado, límites de frecuencia, instalación repetida, conservación de otros ajustes, silencio e invocación segura del motor.
