# Nix Systems Infrastructure

![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=for-the-badge&logo=NixOS&logoColor=white)
![nix-darwin](https://img.shields.io/badge/nix--darwin-314A68?style=for-the-badge&logo=NixOS&logoColor=white)
![Latest Release](https://img.shields.io/github/v/release/themakunga/nix-systems?style=for-the-badge&color=success)

<!-- mtoc-start -->

- [English](#english)
  - [Overview](#overview)
  - [Hosts Description](#hosts-description)
  - [Installation Guide](#installation-guide)
  - [Switch Linux hosts remotely](#switch-linux-hosts-remotely)
  - [Umami on Motherbase](#umami-on-motherbase)
  - [Raspberry Pi: Download & Flash SD Images](#raspberry-pi-download--flash-sd-images)
  - [Repository Workflow (GitFlow)](#repository-workflow-gitflow)
  - [Accessibility](#accessibility)
    - [VoiceOver: screen reader on macOS](#voiceover-screen-reader-on-macos)
    - [STT: dictate with Handy](#stt-dictate-with-handy)
    - [First use and limitations](#first-use-and-limitations)
  - [Recent features and configuration](#recent-features-and-configuration)
  - [Local Development](#local-development)
- [Español](#español)
  - [Descripción](#descripción)
  - [Descripción de Hosts](#descripción-de-hosts)
  - [Guía de Instalación](#guía-de-instalación)
  - [Raspberry Pi: Descarga y Grabación de Imágenes SD](#raspberry-pi-descarga-y-grabación-de-imágenes-sd)
  - [Flujo de Repositorio (GitFlow)](#flujo-de-repositorio-gitflow)
  - [Accesibilidad](#accesibilidad)
    - [VoiceOver: lector de pantalla de macOS](#voiceover-lector-de-pantalla-de-macos)
    - [STT: dictar con Handy](#stt-dictar-con-handy)
    - [Primer uso y límites](#primer-uso-y-límites)
  - [Funciones y configuración recientes](#funciones-y-configuración-recientes)
  - [Desarrollo Local](#desarrollo-local)

<!-- mtoc-end -->

[English](#english) | [Español](#español)

---

## English

### Overview

This repository contains the declarative and reproducible infrastructure for my
personal homelab, workstations, and IoT devices using NixOS and Nix-Darwin
Flakes. It emphasizes strict CI/CD pipelines, secure secret management with
SOPS, and automated artifact generation for ARM64 devices.

### Hosts Description

The infrastructure is divided into three main architectures:

**🍎 Apple Silicon / macOS (nix-darwin)**

- **`kanagawa`:** Primary macOS workstation.
- **`outer-heaven`:** Secondary macOS device / laptop.

**🐧 Linux x86_64 (NixOS)**

- **`msf`:** Main server / workstation.
- **`motherbase`:** Central home server infrastructure.
- **`steamdeck`:** Handheld gaming PC configuration.

**🍓 Linux aarch64 (Raspberry Pi / SBCs)**

- **`aperture-science`:** ARM64 node.
- **`black-mesa`:** SBC running specific homelab services (e.g., PiKVM /
  uStreamer).
- **`valve`:** Additional ARM64 utility node.

_(Note: `lsp-dummy` is used internally across all platforms for CI/CD Language
Server caching)._

### Installation Guide

To apply these configurations to an existing machine running NixOS or macOS with
Nix installed:

**For NixOS machines (x86_64 / aarch64):**

```bash
sudo nixos-rebuild switch --flake github:themakunga/nix-systems#<hostname>
```

**For macOS machines (nix-darwin):**

```bash
darwin-rebuild switch --flake github:themakunga/nix-systems#<hostname>
```

### Switch Linux hosts remotely

From the repository on macOS or Linux, apply these hosts' configurations over SSH:

```bash
make switch-motherbase TARGET_IP=motherbase.local
make switch-msf TARGET_IP=msf.local
make switch-aperture TARGET_IP=aperture-science.local
```

Each target defaults to its host's `.local` name; `TARGET_IP` also accepts an IP address.
For `switch-aperture`, the existing `APERTURE_IP` override remains supported when
`TARGET_IP` is not explicitly supplied. Its default is now `aperture-science.local`.
The build and activation run on `root@TARGET_IP`, requiring root SSH access. To use another
builder, add `BUILD_HOST=builder@linux-builder`. `deploy-motherbase` is a compatibility alias.
These targets do not stage files in Git or use local `sudo`. Existing tracked worktree changes are still part of the flake;
review them before applying. This switches the complete host configuration.

Check command routing without contacting or activating any host:

```bash
python3 scripts/check-motherbase-switch.py
```

### Umami on Motherbase

The Motherbase-only `applicationModules.umami` module declares a Compose project at
`/opt/umami`, managed by `compose-umami.service` through the existing Podman Docker API.
It serves `http://motherbase.local:8989`, bound to the current LAN address
`192.168.5.153`; firewall access is limited to `enp2s0` and `192.168.4.0/22`.
Update both the Compose binding and firewall rule if the LAN address changes.

Umami 3.5.0 runs with PostgreSQL 15 on an internal database network. PostgreSQL has no
published port, and its data persists in the `umami_umami-db-data` volume. Never use
`docker compose down -v` unless intentionally deleting the analytics database.
Back up that database before upgrading either image.

SOPS renders a root-only environment file from the encrypted secrets input; no
credentials belong in the Compose file or Nix store. The service waits for SOPS
and `podman.socket`, independently of the ingress/demo stack. SOPS normally renders
secrets during system activation; an explicit dependency on `sops-install-secrets.service`
is added only when `sops.useSystemdActivation` enables that unit.

Check both SOPS activation modes without starting containers or switching the host:

```sh
nix eval --impure --json --file scripts/check-umami-systemd.nix
```

This declaration requires host activation before the URL is available. After activation,
check `systemctl status compose-umami` and `curl --fail http://motherbase.local:8989/api/heartbeat`.
The first login is `admin` / `umami`; replace the default password immediately.
The requested LAN endpoint uses HTTP. Trackers embedded in public HTTPS websites
need a separately configured HTTPS endpoint reachable by their visitors.

### Raspberry Pi: Download & Flash SD Images

The release pipeline builds an `aperture-bootstrap` ARM64 SD installer and a
`linux-bootstrap` x86_64 ISO. Use the bootstrap installer before applying a host configuration.

**📥 1. Download the Image** Grab the latest `.img.zst` file for your desired
host from the
[Latest GitHub Release](https://github.com/themakunga/nix-systems/releases/latest).

**📦 2. Decompress the Image** The images are compressed using `zstd`. You need
to decompress them before flashing:

```bash
# On Linux/macOS
unzstd '<downloaded-image>.img.zst'
```

**💾 3. Flash to SD Card** You can use graphical tools like **BalenaEtcher** or
**Raspberry Pi Imager** to flash the extracted `.img` file. Alternatively, use
the `dd` command (be careful with the target drive `/dev/sdX`):

```bash
sudo dd if='<downloaded-image>.img' of=/dev/sdX bs=4M status=progress
sync
```

### Repository Workflow (GitFlow)

1. **`develop`:** integration and default branch. Pushes and pull requests run CI and
   security checks. The manual **Promote develop to main** workflow opens a promotion
   PR and builds a prerelease; it does not merge `main` automatically.
2. **`main`:** stable source approved by the owner. **Release** always snapshots this
   branch once, then builds both installers from that exact commit. It never pushes
   a changelog commit to `main`.
3. **Manual stable release:** open **Actions → Release → Run workflow**, select
   `develop` (or `main` after the updated workflow reaches it), and choose `auto`,
   `patch`, `minor` or `major`. The selected workflow branch does not change the
   installer source: it is always `main`.
4. **Weekly stable release:** Mondays at **10:00 UTC**, the workflow checks for new
   main commits. With none, it skips the builds. `auto` uses Conventional Commits:
   breaking changes increment major, `feat` increments minor, and other new commits
   increment patch, including dependency updates. Historical prerelease/date tags
   do not participate in stable version calculation.
5. **Publication:** both nonempty installers must succeed before a tag is created.
   GitHub's workflow token publishes a draft, uploads the images, generated
   `CHANGELOG.md` and `SHA256SUMS`, then marks the release published/latest. A retry
   can resume an unfinished draft; a published version is left unchanged.

The stable installer targets are `aperture-bootstrap` (ARM64 SD image) and
`linux-bootstrap` (x86_64 ISO). Download them from
[Releases](https://github.com/themakunga/nix-systems/releases); these are bootstrap
installers, not an image for every configured host. The generated changelog is a
release asset; publication does not rewrite the repository's historical changelog.
The workflow uses `GITHUB_TOKEN` for tags/releases; a separate `RELEASE_TOKEN` is
not required. Existing private-input and Cachix credentials remain necessary for
image builds. Never add credential values to this README.

Check release behavior locally without publishing or building images:

```sh
python3 -m unittest discover -s tests -p test_release_pipeline.py
actionlint .github/workflows/release.yaml
```

### Accessibility

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
boundaries depend on the target app. See [permissions and checks](docs/point-reader.md).

**Handy:** offline English/Spanish dictation uses Whisper medium Q8 on macOS and
Whisper small Q8 on Linux. On macOS, Ctrl + Alt + Space toggles transcription;
Handy starts hidden at login. Grant microphone and Accessibility permissions when
requested. Models are fetched during provisioning; transcription runs locally.
Activation seeds settings from `public-dotfiles/handy/` only when absent and preserves
existing preferences. Translation, post-processing and automatic submission are
disabled initially. Linux defaults use `wtype` and Ctrl + Shift + V for pasting.

#### VoiceOver: screen reader on macOS

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

#### STT: dictate with Handy

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

#### First use and limitations

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

### Recent features and configuration

| Feature | Declared scope | Configuration |
| --- | --- | --- |
| Point Reader | `kanagawa`, `outer-heaven` | `my.apps.point-reader.enable` |
| Handy dictation | Both Macs and `aperture-science` | `my.apps.handy.enable` |
| Agent vault integration | Hosts enabling the agent wiki | `my.agentWiki.enable`, `my.agentWiki.autoSync.enable` |
| Optional macOS audio devices | Hosts enabling the audio module | `my.devices.audio.enable` |

See [Accessibility](#accessibility) for reading, dictation, shortcuts and permissions.

**Agent integration:** the shared vault beneath `~/.vaults/` supplies agent instructions
and the standalone GLaDOS skill. Activation registers configured hooks for Codex,
Claude Code and Hermes, reporting `OK: GLaDOS <agent>` on success instead of full JSON.
Hook registration and voice authorization are separate; existing runtime permissions
still apply. Optional vault synchronization defaults to a 300-second interval.

**Quieter macOS activation:** successful Mac App Store operations report `OK: <app>`;
already-installed chatter is suppressed. Audio selects `HyperX QuadCast` as input and
`head radio` as output only when present. Missing optional devices are silent;
successful selection prints OK and actual failures retain their diagnostics.
Both normal and bootstrap-fix Mac targets use `sudo -H` for profile updates and
activation so root does not inherit the user's HOME:

```sh
make switch-kanagawa
make switch-outer-heaven
```

These commands build and activate the complete host configuration and run `git add -A`.
Review pending work first. A dirty Git warning remains expected with uncommitted files.
Validate the output behavior without installing apps or changing audio devices:

```sh
python3 scripts/check-mas-activation.py
python3 scripts/check-quiet-activation.py
```

**Reproducible CI:** `CI — Check & Dry-run` runs lint, flake evaluation and dry-runs
for the six Linux hosts on pushes and pull requests to `develop`. Lint resolves
`pre-commit`, Statix and Alejandra from the primary nixpkgs revision in `flake.lock`.
Its environment cache is keyed by both the hook configuration and lockfile, preventing
reuse across incompatible toolchain revisions. Security scanning runs separately.
CI checks and dry-runs do not activate any host.

### Local Development

To enter the development environment with all required tools (`alejandra`,
`statix`, `deadnix`, `sops`, `pre-commit`), simply run:

```bash
nix develop
```

This devshell automatically loads the necessary dependencies. Before committing
any changes, you can manually run the formatting and linting hooks using:

```bash
pre-commit run --all-files
```

### Comprobar advertencias y dotfiles

En macOS, Docker y Docker Compose usan la API de Podman. Al iniciar sesión,
el agente `org.nixos.podman` crea la VM si falta (4 CPU, 8 GiB), la arranca y
enlaza su socket. Después de aplicar cambios con `darwin-rebuild switch`, abre
una terminal nueva para cargar `DOCKER_HOST`. Los datos existentes de Colima
se conservan; sus imágenes y volúmenes no se migran automáticamente.

```bash
nix eval --offline --impure --json --file scripts/check-containers.nix
podman machine list
docker info
docker compose version
```

Los errores de arranque quedan en `/tmp/podman.err`. Si detienes la VM
manualmente, puedes volver a iniciarla con `podman machine start`.

```bash
python3 scripts/check-dotfiles.py ~/.public-dotfiles
nix flake check --no-build --all-systems --no-write-lock-file
```

La primera comprobación evalúa todos los hosts sin activarlos y falla si hay
carpetas de dotfiles ausentes o advertencias de configuración. Los módulos de
desarrollo no enlazan dotfiles por defecto: activa `useDotfiles` únicamente
cuando exista la carpeta correspondiente en el repositorio público.

Pendiente: `aperture-bootstrap` y `valve` conservan el initrd clásico por el fallo
de arranque documentado en `sd-image-rpi5.nix`. Su migración a systemd requiere
una prueba de arranque en Raspberry Pi 5; la comprobación mantiene visible esa
advertencia y devuelve un estado de fallo mientras siga pendiente.

Los mensajes de Git sobre cambios sin commit y los de Nix sobre outputs propios
(`applicationModules`, `bundle`, etc.) son informativos. La advertencia de
`extra-substituters` indica que Nix no ha autorizado la caché declarada por el
flake; no se habilita confianza global ni se ocultan estas advertencias.

---

## Español

### Descripción

Este repositorio contiene la infraestructura declarativa y reproducible para mi
homelab personal, estaciones de trabajo y dispositivos IoT utilizando NixOS y
Flakes de Nix-Darwin. Destaca por sus estrictos pipelines de CI/CD, gestión
segura de secretos con SOPS y generación automatizada de artefactos para
dispositivos ARM64.

### Descripción de Hosts

La infraestructura está dividida en tres arquitecturas principales:

**🍎 Apple Silicon / macOS (nix-darwin)**

- **`kanagawa`:** Estación de trabajo principal en macOS.
- **`outer-heaven`:** Dispositivo secundario macOS / laptop.

**🐧 Linux x86_64 (NixOS)**

- **`msf`:** Servidor principal / estación de trabajo.
- **`motherbase`:** Infraestructura central del servidor doméstico.
- **`steamdeck`:** Configuración para la consola portátil.

**🍓 Linux aarch64 (Raspberry Pi / SBCs)**

- **`aperture-science`:** Nodo ARM64.
- **`black-mesa`:** SBC ejecutando servicios específicos del homelab (ej. PiKVM
  / uStreamer).
- **`valve`:** Nodo de utilidad ARM64 adicional.

_(Nota: `lsp-dummy` se utiliza internamente en todas las plataformas para el
almacenamiento en caché del CI/CD)._

### Guía de Instalación

Para aplicar estas configuraciones a una máquina existente que ejecute NixOS o
macOS con Nix instalado:

**Para máquinas NixOS (x86_64 / aarch64):**

```bash
sudo nixos-rebuild switch --flake github:themakunga/nix-systems#<hostname>
```

**Para máquinas macOS (nix-darwin):**

```bash
darwin-rebuild switch --flake github:themakunga/nix-systems#<hostname>
```

### Raspberry Pi: Descarga y Grabación de Imágenes SD

El pipeline genera un instalador SD ARM64 `aperture-bootstrap` y una ISO x86_64
`linux-bootstrap`. El instalador inicial permite después aplicar la configuración del host.

**📥 1. Descargar la Imagen** Descarga el archivo `.img.zst` más reciente para
tu host desde el apartado de
[Último GitHub Release](https://github.com/themakunga/nix-systems/releases/latest).

**📦 2. Descomprimir la Imagen** Las imágenes están comprimidas usando `zstd`.
Debes descomprimirlas antes de grabarlas:

```bash
# En Linux/macOS
unzstd '<downloaded-image>.img.zst'
```

**💾 3. Grabar en la Tarjeta SD** Puedes usar herramientas gráficas como
**BalenaEtcher** o **Raspberry Pi Imager** para grabar el archivo `.img`
extraído. Alternativamente, puedes usar el comando `dd` (ten cuidado de elegir
la unidad `/dev/sdX` correcta):

```bash
sudo dd if='<downloaded-image>.img' of=/dev/sdX bs=4M status=progress
sync
```

### Flujo de Repositorio (GitFlow)

1. **`develop`:** rama de integración y predeterminada. Los pushes y PR ejecutan CI
   y seguridad. **Promote develop to main** abre un PR de promoción y genera un
   prerelease; no fusiona `main` automáticamente.
2. **`main`:** fuente estable aprobada por el propietario. **Release** toma una única
   revisión de esta rama y construye ambos instaladores desde ella. No publica
   commits de changelog en `main`.
3. **Release manual:** abre **Actions → Release → Run workflow**, selecciona `develop`
   (o `main` cuando incorpore el workflow actualizado) y elige `auto`, `patch`, `minor`
   o `major`. Las imágenes siempre proceden de `main`, independientemente de la rama
   elegida para ejecutar el workflow.
4. **Release semanal:** cada lunes a las **10:00 UTC**, comprueba si hay commits nuevos
   en `main`. Sin cambios, omite las compilaciones. `auto` sigue Conventional Commits:
   cambios incompatibles incrementan la versión mayor, `feat` la menor y el resto
   incrementa el parche, incluidas las actualizaciones de dependencias. Los tags de
   prerelease o fecha no intervienen en el cálculo de versiones estables.
5. **Publicación:** exige ambos instaladores completos antes de crear el tag. Publica
   primero un borrador, adjunta imágenes, `CHANGELOG.md` y `SHA256SUMS`, y lo hace
   público al terminar. Los nuevos intentos completan borradores pendientes y
   conservan intactos los releases ya publicados.

Los destinos son `aperture-bootstrap` (imagen SD ARM64) y `linux-bootstrap` (ISO
x86_64). Se descargan desde [Releases](https://github.com/themakunga/nix-systems/releases).
Son instaladores iniciales; no se genera una imagen distinta para cada host. El
changelog generado se adjunta al release y no reemplaza el archivo histórico del
repositorio. Tags y releases usan `GITHUB_TOKEN`, sin necesitar `RELEASE_TOKEN`.
Las credenciales existentes para inputs privados y Cachix siguen siendo necesarias;
no copies sus valores al README.

Comprueba el flujo sin publicar ni construir imágenes:

```sh
python3 -m unittest discover -s tests -p test_release_pipeline.py
actionlint .github/workflows/release.yaml
```

### Accesibilidad

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
  [guía de permisos y comprobaciones](docs/point-reader.md).
- **Handy:** `my.apps.handy.enable` declara dictado local en inglés y español en
  ambos Mac y `aperture-science`. Usa Whisper medium Q8 en macOS y small Q8 en Linux.
  En macOS, Ctrl + Alt + Space alterna la transcripción y la app inicia oculta.
  Requiere los permisos de micrófono y Accesibilidad correspondientes. La configuración
  inicial procede de `public-dotfiles/handy/` y conserva las preferencias existentes.
  Los modelos se descargan al preparar el sistema; la transcripción es local.
#### VoiceOver: lector de pantalla de macOS

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

#### STT: dictar con Handy

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

#### Primer uso y límites

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

### Funciones y configuración recientes

Consulta [Accesibilidad](#accesibilidad) para lectura, dictado, atajos y permisos.

- **Agentes:** `my.agentWiki.enable` conecta el vault de `~/.vaults/` y sus instrucciones.
  La integración de Codex, Claude Code y Hermes muestra una línea OK por agente.
  Registrar hooks no concede autorización de voz. `my.agentWiki.autoSync.enable`
  controla la sincronización periódica; el intervalo predeterminado es 300 segundos.
- **Activación macOS:** MAS muestra `OK: nombre` cuando termina correctamente.
  `my.devices.audio.enable` selecciona HyperX QuadCast y head radio solo si están
  presentes. Los dispositivos ausentes son silenciosos; los errores reales conservan
  su diagnóstico. Los cuatro destinos Mac usan `sudo -H` para el perfil y la activación.
- **CI:** las herramientas de lint usan la revisión primaria de nixpkgs de `flake.lock`.
  La caché incluye el archivo de bloqueo y la configuración de hooks. CI comprueba
  formato, evaluación y dry-runs de los seis hosts Linux; seguridad se ejecuta aparte.

Las opciones anteriores describen la configuración declarada; requieren activación
para aplicarse. `make switch-kanagawa` y `make switch-outer-heaven` construyen y
activan el sistema completo, y ejecutan `git add -A`: revisa los cambios pendientes
antes de usarlos. El aviso de Git sucio permanece mientras haya archivos sin commit.
Las comprobaciones de MAS y audio no instalan aplicaciones ni cambian dispositivos:

```sh
python3 scripts/check-mas-activation.py
python3 scripts/check-quiet-activation.py
```

### Desarrollo Local

Para entrar al entorno de desarrollo con todas las herramientas necesarias
instaladas (`alejandra`, `statix`, `deadnix`, `sops`, `pre-commit`), simplemente
ejecuta:

```bash
nix develop
```

Esta terminal (devshell) carga automáticamente todas las dependencias. Antes de
hacer commit a tus cambios, puedes ejecutar manualmente los formateadores y
linters usando:

```bash
pre-commit run --all-files
```
