# Accessibility / Accesibilidad

[README](../README.md)

[English](#english) | [Español](#español)

## English

Point Reader and Handy provide complementary ways to read and enter text. Both are
declared on `kanagawa` and `outer-heaven`; Handy is also declared on `aperture-science`.

| Task on macOS | Shortcut | Behavior |
| --- | --- | --- |
| Read selected text | Shift + Command + Space | Point Reader speaks the active selection using the system voice. |
| Read text under the pointer | Shift + Command + Space, without a selection | Reads the accessible block under the pointer. |
| Stop reading | Repeat Shift + Command + Space | Stops current speech; Stop Reading is also available in the Read menu. |
| Dictate text | Ctrl + Alt + Space | Handy toggles recording for local transcription. |

**Point Reader:** Shift + Command + Space reads the selected text, or the accessible
text block under the pointer when there is no selection. Repeat the shortcut to stop.
The app starts at login and uses the system voice. After host activation, grant the
Point Reader app Accessibility permission in System Settings. There is no OCR; block
boundaries depend on the target app. See [permissions and checks](point-reader.md).

**Handy:** offline English/Spanish dictation uses Whisper medium Q8 on macOS and
Whisper small Q8 on Linux. On macOS, Ctrl + Alt + Space toggles transcription;
Handy starts hidden at login. Grant microphone and Accessibility permissions when
requested. Models are fetched during provisioning; transcription runs locally.
Activation seeds settings from `public-dotfiles/handy/` only when absent and preserves
existing preferences. Translation, post-processing and automatic submission are
disabled initially. Linux defaults use `wtype` and Ctrl + Shift + V for pasting.

### VoiceOver: screen reader on macOS

VoiceOver is built into macOS and can read interface controls and navigate apps.
This repository does not enable it automatically or override its personal settings.

1. Press **Command + F5** to turn it on or off. Depending on keyboard settings, add
   **Fn**. Alternatively, use **System Settings → Accessibility → VoiceOver**.
2. In the commands below, **VO** means **Control + Option**; Caps Lock may also be
   configured as the VoiceOver modifier. Alt on these keyboards means Option on macOS.
3. Use **VO + Left/Right Arrow** to move between items and **VO + Space** to activate one.
   Use **VO + Shift + Down Arrow** to interact with a group and **VO + Shift + Up Arrow**
   to leave it. Use the VoiceOver tutorial to practice before navigating a terminal.
4. Adjust voice, speaking rate and verbosity in VoiceOver Utility. Use Command + F5
   again when you want to stop using the screen reader.

For occasional reading of selected or pointed text, the Point Reader shortcut remains
Shift + Command + Space. VoiceOver controls the broader accessible interface.
See Apple's [VoiceOver startup guide](https://support.apple.com/guide/voiceover/vo2682/mac)
and [navigation commands](https://support.apple.com/guide/voiceover/cpvokys04/mac).

### STT: dictate with Handy

STT (speech to text) is provided here by Handy. To write a message, shell command or
editor text:

1. Open Handy and confirm its local model is ready. On macOS, allow Microphone and
   Accessibility access when requested. Existing preferences may override the defaults.
2. Focus the destination text field. In Neovim enter insert mode; in a terminal focus
   an editable prompt. In tmux, select the destination pane first.
3. Press **Ctrl + Alt + Space** once and speak in English or Spanish. On macOS,
   **Alt = Option**. Press the same shortcut again to stop recording, transcribe and paste.
4. Review the inserted text before pressing Enter. Automatic submission is disabled;
   inspect dictated shell commands before executing them.

On `aperture-science`, Hyprland launches Handy and binds the same shortcut to
`handy --toggle-transcription`; `wtype` and `wl-clipboard` support terminal pasting.
When using SSH, Handy records from the microphone on the computer running the app,
not from the remote server. If nothing is inserted, check focus, permissions, microphone,
model availability and shortcut conflicts in Handy. Models run locally after provisioning.

### First use and limitations

1. Activate the host configuration separately; Point Reader and Handy start at login on macOS.
2. Grant **Point Reader** permission under **System Settings → Privacy & Security → Accessibility**.
   Grant permissions to the app itself, not Terminal; restart if requested. App updates may
   require renewed permission.
3. Grant **Handy** microphone and Accessibility permissions when requested. Test dictation
   in a text editor before using it in another app; automatic submission is initially disabled.
4. Select a paragraph and test reading, repeat the shortcut to stop, then clear the selection
   and test a text block under the pointer. Resolve any shortcut conflict before retrying.

Point Reader excludes protected fields and their descendants. It neither logs text nor copies
it to the clipboard. It requires accessible text: images, canvas content and apps without
accessible text are unsupported. When an app exposes an entire document instead of a block,
select the exact text first. Missing readable text produces a brief system sound.

These declarations do not grant macOS permissions automatically. Physical microphone, audio,
shortcut and multi-display acceptance must be checked on each host after activation.

## Español

Point Reader permite escuchar texto y Handy permite introducirlo mediante dictado.
Ambos están declarados en `kanagawa` y `outer-heaven`; Handy también está en
`aperture-science`.

| Acción en macOS | Atajo | Resultado |
| --- | --- | --- |
| Leer la selección | Shift + Command + Space | Lee el texto seleccionado con la voz del sistema. |
| Leer bajo el puntero | Mismo atajo, sin selección | Lee el bloque de texto accesible señalado. |
| Detener la lectura | Repetir el atajo | También disponible en Read → Stop Reading. |
| Dictar texto | Ctrl + Alt + Space | Handy alterna la grabación para transcribir localmente. |

- **Point Reader:** declarado en ambos Mac con `my.apps.point-reader.enable`.
  Shift + Command + Space lee la selección o el bloque accesible bajo el puntero;
  repetir el atajo detiene la lectura. Inicia al entrar a la sesión y necesita permiso
  de Accesibilidad para la aplicación. No incluye OCR. Consulta la
  [guía de permisos y comprobaciones](point-reader.md).
- **Handy:** `my.apps.handy.enable` declara dictado local en inglés y español en
  ambos Mac y `aperture-science`. Usa Whisper medium Q8 en macOS y small Q8 en Linux.
  En macOS, Ctrl + Alt + Space alterna la transcripción y la app inicia oculta.
  Requiere los permisos de micrófono y Accesibilidad correspondientes. La configuración
  inicial procede de `public-dotfiles/handy/` y conserva las preferencias existentes.
  Los modelos se descargan al preparar el sistema; la transcripción es local.
### VoiceOver: lector de pantalla de macOS

VoiceOver viene incluido en macOS y permite escuchar controles y navegar por las
aplicaciones. Este repositorio no lo activa automáticamente ni reemplaza tus preferencias.

1. Pulsa **Command + F5** para activarlo o desactivarlo; según el teclado, añade **Fn**.
   También puedes usar **Ajustes del Sistema → Accesibilidad → VoiceOver**.
2. **VO** representa **Control + Option**. Bloq Mayús también puede configurarse como
   modificador de VoiceOver. En macOS, Alt corresponde a Option.
3. **VO + flecha izquierda/derecha** recorre los elementos; **VO + Espacio** activa uno.
   **VO + Shift + flecha abajo** entra en un grupo y **VO + Shift + flecha arriba** sale.
   Practica con el tutorial de VoiceOver antes de navegar por una terminal.
4. Ajusta voz, velocidad y nivel de detalle en Utilidad VoiceOver. Command + F5 vuelve
   a desactivar el lector cuando termines.

Para lecturas puntuales de una selección o del texto bajo el puntero, Point Reader
conserva Shift + Command + Space. VoiceOver permite recorrer la interfaz accesible completa.
Consulta la [guía de inicio de Apple](https://support.apple.com/guide/voiceover/vo2682/mac)
y los [comandos de navegación](https://support.apple.com/guide/voiceover/cpvokys04/mac).

### STT: dictar con Handy

STT significa convertir voz en texto; en esta configuración lo proporciona Handy.
Para escribir mensajes, comandos o texto del editor:

1. Abre Handy y comprueba que el modelo local está preparado. En macOS, concede los
   permisos de Micrófono y Accesibilidad solicitados. Tus preferencias guardadas pueden
   reemplazar la configuración inicial.
2. Enfoca el campo de destino. En Neovim entra en modo inserción; en la terminal sitúate
   en un prompt editable. En tmux, selecciona primero el panel de destino.
3. Pulsa **Ctrl + Alt + Espacio** una vez y habla en español o inglés. En macOS,
   **Alt = Option**. Repite el atajo para detener la grabación, transcribir y pegar.
4. Revisa el texto antes de pulsar Enter. El envío automático está desactivado;
   comprueba los comandos dictados antes de ejecutarlos.

En `aperture-science`, Hyprland inicia Handy y enlaza el mismo atajo con
`handy --toggle-transcription`; `wtype` y `wl-clipboard` permiten pegar en la terminal.
Si usas SSH, se graba desde el micrófono del equipo donde corre Handy, no desde el
servidor remoto. Si no aparece texto, revisa el foco, permisos, micrófono, modelo y
conflictos de atajos en Handy. Tras preparar los modelos, la transcripción es local.

### Primer uso y límites

1. Activa la configuración del host por separado. Ambas aplicaciones inician al entrar
   en la sesión de macOS.
2. Autoriza **Point Reader** en **Ajustes del Sistema → Privacidad y seguridad → Accesibilidad**.
   El permiso corresponde a la aplicación, no a Terminal. Reiníciala si macOS lo solicita;
   una actualización puede requerir renovar el permiso.
3. Autoriza micrófono y Accesibilidad para **Handy** cuando lo solicite. Prueba primero
   en un editor de texto; el envío automático está desactivado inicialmente.
4. Prueba lectura de una selección, detención con el mismo atajo y lectura bajo el puntero
   sin selección. Resuelve cualquier conflicto de atajos antes de repetir la prueba.

Point Reader excluye campos protegidos y sus descendientes. No registra el texto ni lo copia
al portapapeles. No lee imágenes, contenido de canvas ni aplicaciones sin texto accesible.
Si una aplicación expone el documento completo en lugar de un bloque, selecciona el texto
exacto. Cuando no encuentra texto legible, emite un sonido breve.

La configuración no concede permisos de macOS automáticamente. Micrófono, audio, atajos y
comportamiento con varias pantallas requieren comprobación física en cada host tras activarlo.
