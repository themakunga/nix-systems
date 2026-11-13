# Nix Systems Infrastructure

![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=for-the-badge&logo=NixOS&logoColor=white)
![nix-darwin](https://img.shields.io/badge/nix--darwin-314A68?style=for-the-badge&logo=NixOS&logoColor=white)
![Latest Release](https://img.shields.io/github/v/release/themakunga/nix-systems?style=for-the-badge&color=success)

<!-- mtoc-start -->

- [English](#english)
  - [Overview](#overview)
  - [Hosts Description](#hosts-description)
  - [Installation Guide](#installation-guide)
  - [Switch motherbase remotely](#switch-motherbase-remotely)
  - [Raspberry Pi: Download & Flash SD Images](#raspberry-pi-download--flash-sd-images)
  - [Repository Workflow (GitFlow)](#repository-workflow-gitflow)
  - [Local Development](#local-development)
- [Español](#español)
  - [Descripción](#descripción)
  - [Descripción de Hosts](#descripción-de-hosts)
  - [Guía de Instalación](#guía-de-instalación)
  - [Raspberry Pi: Descarga y Grabación de Imágenes SD](#raspberry-pi-descarga-y-grabación-de-imágenes-sd)
  - [Flujo de Repositorio (GitFlow)](#flujo-de-repositorio-gitflow)
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

### Switch motherbase remotely

From the repository on macOS or Linux, apply motherbase's configuration over SSH:

```bash
make switch-motherbase TARGET_IP=motherbase.local
```

`TARGET_IP` defaults to `motherbase.local` for this target and also accepts an IP address.
The build and activation run on `root@TARGET_IP`, requiring root SSH access. To use another
builder, add `BUILD_HOST=builder@linux-builder`. `deploy-motherbase` is a compatibility alias.
Neither target stages files in Git. Existing tracked worktree changes are still part of the flake;
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
and `podman.socket`, independently of the ingress/demo stack.

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
