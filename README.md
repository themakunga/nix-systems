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
  - [Recent features and configuration](#recent-features-and-configuration)
  - [Local Development](#local-development)
- [Español](#español)
  - [Descripción](#descripción)
  - [Descripción de Hosts](#descripción-de-hosts)
  - [Guía de Instalación](#guía-de-instalación)
  - [Raspberry Pi: Descarga y Grabación de Imágenes SD](#raspberry-pi-descarga-y-grabación-de-imágenes-sd)
  - [Flujo de Repositorio (GitFlow)](#flujo-de-repositorio-gitflow)
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

SD Card images for ARM64 hosts (`aperture-science`, `black-mesa`, `valve`) are
automatically compiled, compressed, and published by the CI/CD pipeline.

**📥 1. Download the Image** Grab the latest `.img.zst` file for your desired
host from the
[Latest GitHub Release](https://github.com/themakunga/nix-systems/releases/latest).

**📦 2. Decompress the Image** The images are compressed using `zstd`. You need
to decompress them before flashing:

```bash
# On Linux/macOS
unzstd aperture-science-sd-image.img.zst
```

**💾 3. Flash to SD Card** You can use graphical tools like **BalenaEtcher** or
**Raspberry Pi Imager** to flash the extracted `.img` file. Alternatively, use
the `dd` command (be careful with the target drive `/dev/sdX`):

```bash
sudo dd if=aperture-science-sd-image.img of=/dev/sdX bs=4M status=progress
sync
```

### Repository Workflow (GitFlow)

This repository enforces a strict, automated GitFlow architecture using GitHub
Rulesets:

1. **`develop` branch:** The integration branch. Pushing here triggers the
   **Auto Pre-Release** pipeline, building nightly/test images.
2. **Release Train:** Triggering the **Start Release** workflow from GitHub
   Actions creates a `release/v*` branch and opens a Pull Request to `main`.
3. **PR Checks:** The PR strictly validates Darwin, Linux x86, and Linux ARM
   builds via Cachix.
4. **`main` branch:** Protected production branch. Merging the PR triggers the
   **Semantic Release** pipeline, which publishes the final artifacts, generates
   the `CHANGELOG.md`, and creates the GitHub Release.

### Recent features and configuration

| Feature | Declared scope | Configuration |
| --- | --- | --- |
| Point Reader | `kanagawa`, `outer-heaven` | `my.apps.point-reader.enable` |
| Handy dictation | Both Macs and `aperture-science` | `my.apps.handy.enable` |
| Agent vault integration | Hosts enabling the agent wiki | `my.agentWiki.enable`, `my.agentWiki.autoSync.enable` |
| Optional macOS audio devices | Hosts enabling the audio module | `my.devices.audio.enable` |

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

Las imágenes de tarjeta SD para los hosts ARM64 (`aperture-science`,
`black-mesa`, `valve`) son compiladas, comprimidas y publicadas automáticamente
por el pipeline de CI/CD.

**📥 1. Descargar la Imagen** Descarga el archivo `.img.zst` más reciente para
tu host desde el apartado de
[Último GitHub Release](https://github.com/themakunga/nix-systems/releases/latest).

**📦 2. Descomprimir la Imagen** Las imágenes están comprimidas usando `zstd`.
Debes descomprimirlas antes de grabarlas:

```bash
# En Linux/macOS
unzstd aperture-science-sd-image.img.zst
```

**💾 3. Grabar en la Tarjeta SD** Puedes usar herramientas gráficas como
**BalenaEtcher** o **Raspberry Pi Imager** para grabar el archivo `.img`
extraído. Alternativamente, puedes usar el comando `dd` (ten cuidado de elegir
la unidad `/dev/sdX` correcta):

```bash
sudo dd if=aperture-science-sd-image.img of=/dev/sdX bs=4M status=progress
sync
```

### Flujo de Repositorio (GitFlow)

Este repositorio impone una arquitectura estricta y automatizada mediante
Rulesets de GitHub:

1. **Rama `develop`:** La rama de integración. Hacer push aquí dispara el
   pipeline **Auto Pre-Release**, construyendo imágenes de prueba de forma
   nocturna.
2. **Tren de Lanzamiento:** Al ejecutar el workflow **Start Release** desde
   GitHub Actions, se crea una rama `release/v*` y se abre un Pull Request hacia
   `main`.
3. **Validación de PR:** El PR valida estrictamente las compilaciones de Darwin,
   Linux x86 y Linux ARM apoyándose en Cachix.
4. **Rama `main`:** Rama de producción protegida. Al fusionar (merge) el PR, se
   dispara el pipeline de **Semantic Release**, el cual publica los artefactos
   finales, genera el `CHANGELOG.md` y crea el Release oficial en GitHub.

### Funciones y configuración recientes

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
