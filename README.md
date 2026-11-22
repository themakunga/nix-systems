# Nix Systems Infrastructure

![NixOS](https://img.shields.io/badge/NixOS-5277C3?style=for-the-badge&logo=NixOS&logoColor=white)
![nix-darwin](https://img.shields.io/badge/nix--darwin-314A68?style=for-the-badge&logo=NixOS&logoColor=white)
![Latest Release](https://img.shields.io/github/v/release/themakunga/nix-systems?style=for-the-badge&color=success)

[English](#english) | [Español](#español)

## English

Declarative infrastructure for personal workstations, homelab servers and ARM
devices, using NixOS, nix-darwin, flakes and SOPS.

### Hosts

| Platform              | Hosts                                                                                 |
| --------------------- | ------------------------------------------------------------------------------------- |
| macOS / Apple Silicon | `kanagawa` (primary workstation), `outer-heaven` (secondary Mac)                      |
| NixOS / x86_64        | `msf` (server/workstation), `motherbase` (home server), `steamdeck` (handheld)        |
| NixOS / aarch64       | `aperture-science` (ARM node), `black-mesa` (PiKVM/uStreamer), `valve` (utility node) |

`lsp-dummy` is an internal configuration for language-server caching.

### Documentation

| Topic                                         | Guide                                             |
| --------------------------------------------- | ------------------------------------------------- |
| Installation, remote deployment and SD images | [Installation](docs/installation.md)              |
| macOS activation, MAS, audio and Podman       | [Darwin](docs/darwin.md)                          |
| Point Reader, VoiceOver and speech to text    | [Accessibility](docs/accessibility.md)            |
| Application options and Umami                 | [Applications and services](docs/applications.md) |
| Shared vault, hooks and synchronization       | [AI agents](docs/agents.md)                       |
| Branches, versioning and release publication  | [Releases](docs/releases.md)                      |
| Development shell, CI and validation          | [Development](docs/development.md)                |
| Point Reader implementation and checks        | [Point Reader](docs/point-reader.md)              |
| iPad keyboard and touchpad                    | [iPad control](docs/ipad-touchpad.md)             |

### Quick start

```sh
nix develop
pre-commit run --all-files
```

See the [installation guide](docs/installation.md) before applying a host
configuration. Download bootstrap installers from the
[latest release](https://github.com/themakunga/nix-systems/releases/latest).
`develop` is the integration branch; stable releases build the owner-approved
`main`.

## Español

Infraestructura declarativa para estaciones de trabajo, servidores domésticos y
nodos ARM con NixOS, nix-darwin, flakes y SOPS. Los hosts aparecen en la tabla
anterior.

### Documentación

| Tema                                         | Guía                                                     |
| -------------------------------------------- | -------------------------------------------------------- |
| Instalación, despliegue remoto e imágenes SD | [Instalación](docs/installation.md#español)              |
| Activación de macOS, MAS, audio y Podman     | [Darwin](docs/darwin.md#español)                         |
| Point Reader, VoiceOver y dictado STT        | [Accesibilidad](docs/accessibility.md#español)           |
| Opciones de aplicaciones y Umami             | [Aplicaciones y servicios](docs/applications.md#español) |
| Vault compartido, hooks y sincronización     | [Agentes de IA](docs/agents.md#español)                  |
| Ramas, versiones y publicación               | [Releases](docs/releases.md#español)                     |
| Entorno de desarrollo, CI y comprobaciones   | [Desarrollo](docs/development.md#español)                |
| Teclado y touchpad desde un iPad             | [Control desde iPad](docs/ipad-touchpad.md)              |

### Inicio rápido

```sh
nix develop
pre-commit run --all-files
```

Consulta [Instalación](docs/installation.md#español) antes de aplicar la
configuración. Los instaladores iniciales están en el
[último release](https://github.com/themakunga/nix-systems/releases/latest).
`develop` integra los cambios; los releases estables se construyen desde `main`,
aprobada por el propietario.

## Repository reference

| Path                       | Purpose                                 |
| -------------------------- | --------------------------------------- |
| [`docs/`](docs/)           | Usage and development guides            |
| [`MODULES.md`](MODULES.md) | Project reference                       |
| [`modules/`](modules/)     | Reusable modules                        |
| [`Makefile`](Makefile)     | Documented build and validation targets |

The default branch is `develop`. Use the tracked manifests and scripts above
when preparing changes; keep local credentials and generated files out of
commits.
