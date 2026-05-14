# Nix Systems Infraestructures


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

---

### Local Development


## español

---

### Descripcion

### Arquitectura y Functiones

### Flujo de Repositorio

### Pipelines CI/CD
