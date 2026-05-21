# Nix Systems Infraestructures

nota. actualizar todo 
<!-- mtoc-start -->

* [english](#english)
  * [Overview](#overview)
  * [Architecture & Features](#architecture--features)
  * [Repository Workflow (GitFlow)](#repository-workflow-gitflow)
  * [CI/CD Pipelines](#cicd-pipelines)
  * [Local Development](#local-development)
* [español](#español)
  * [Descripcion](#descripcion)
  * [Arquitectura y Functiones](#arquitectura-y-functiones)
  * [Flujo de Repositorio](#flujo-de-repositorio)
  * [Pipelines CI/CD](#pipelines-cicd)
  * [Desarrollo Local](#desarrollo-local)

<!-- mtoc-end -->

[English](#englis) | [Español](#espanol)

---

## english

### Overview

This repository contains the declarative and reproducible infrastructure for
the personal homelab and IoT devices using NixOS and Flakes. It emphasizes
strict CI/CD pipelines, secure secret management, and automated artifact
generation.

### Architecture & Features

- **NixOS Flakes:** Fully reproducible system configurations across different
host architectures (x86_64, aarch64).
- **Automated SD Image Generation:** Cross-compiles customized NixOS SD card
images for Raspberry Pi devices (e.g., `Wheatley`, `glaDOS`) directly from
GitHub Actions using QEMU.
- **Secrets Management:** Utilizes `sops-nix` combined with `age` and SSH keys
to securely encrypt private keys and tokens, isolating secrets per host while
maintaining a shared repository.
- **Binary Caching:** Integrated with Cachix to cache build outputs and
significantly reduce CI/CD execution times.
- **Semantic Release:** Fully automated versioning, changelog generation, git
tagging, and GitHub Release deployment based on Conventional Commits.

### Repository Workflow (GitFlow)

This repository enforces a strict GitFlow architecture to ensure stability:
1. **Protected `main` branch:** Direct pushes and force-pushes are disabled.
2. **Pull Requests Required:** All changes must be integrated via Pull Requests.
3. **Branch Enforcement:** PRs targeting `main` must originate exclusively from the `develop` branch.
4. **Release Strategy:** Pushing to a `release/v*` branch triggers the build process, generating the SD images and publishing them as release artifacts.

### CI/CD Pipelines

- **Quality & Linting:** Runs on every push to check Nix flake validity, format code (`alejandra`), run linters (`statix`), and detect unused code (`deadnix`).
- **PR Exhaustive Review:** Runs on PRs to `main`. Validates branch origins and performs a dry-run evaluation of all NixOS hosts to prevent bootloader clashes or evaluation errors.
- **Release Build & Publish:** Cross-compiles the system, packages the `.img.zst` files, and delegates versioning/tagging to Semantic Release.


### Local Development

To enter the development environment with all required tools (`alejandra`, `statix`, `deadnix`, `sops`), use:

```bash
nix develop
```

Alternatively, use the provided `Makefile` commands to run checks locally:

```bash
make alejandra
make statix
make deadnix
```

---
## español


### Descripcion

Este repositorio contiene la infraestructura declarativa y reproducible para un homelab personal y dispositivos IoT utilizando NixOS y Flakes. Destaca por sus estrictos pipelines de CI/CD, gestión segura de secretos y generación automatizada de artefactos.

### Arquitectura y Functiones

- **NixOS Flakes:** Configuraciones de sistema completamente reproducibles a través de múltiples arquitecturas (x86_64, aarch64).
- **Generación Automatizada de Imágenes SD:** Compilación cruzada (cross-compilation) de imágenes de NixOS personalizadas para Raspberry Pi (ej. cornholio, glaDOS) directamente desde GitHub Actions usando QEMU.
- **Gestión de Secretos:** Utiliza sops-nix combinado con llaves age y SSH para encriptar claves privadas y tokens de forma segura, aislando los secretos por host.
- **Caché Binario:** Integración con Cachix para almacenar los resultados de compilación y reducir drásticamente los tiempos de ejecución en el CI/CD.
- **Semantic Release:** Versionado, generación de changelogs, etiquetado en git (tags) y despliegue de GitHub Releases completamente automatizados basados en Conventional Commits.

### Flujo de Repositorio

Este repositorio impone una arquitectura estricta para garantizar la estabilidad:

1. **Rama `main` protegida:** Los push directos y force-pushes están deshabilitados.
2. **Pull Requests Obligatorios:** Todos los cambios deben integrarse mediante Pull Requests.
3. **Restricción de Origen:** Los PRs hacia `main` deben provenir exclusivamente de la rama `develop`.
4. **Estrategia de Release:** Al enviar código a una rama `release/v*`, se dispara el proceso de compilación, generando las imágenes SD y publicándolas como artefactos de lanzamiento.

### Pipelines CI/CD

- **Calidad y Linting:** Se ejecuta en cada push para validar la estructura del flake, formatear el código (`alejandra`), ejecutar linters (`statix`) y detectar código sin uso (`deadnix`).
- **Revisión Exhaustiva de PR:** Se ejecuta en los PRs hacia `main`. Valida el origen de la rama y realiza una evaluación en seco (dry-run) de todos los hosts para prevenir conflictos (ej. colisión de bootloaders) o errores de evaluación.
- **Compilación y Publicación (Release):** Compila el sistema operativo, empaqueta los archivos `.img.zst` y delega el versionado a Semantic Release.

### Desarrollo Local

Para entrar al entorno de desarrollo con todas las herramientas necesarias (`alejandra`, `statix`, `deadnix`, `sops`), utiliza:

```bash
nix develop

```

De forma alternativa, utiliza los comandos provistos en el `Makefile` para realizar validaciones locales:

```bash
make alejandra
make statix
make deadnix

```
