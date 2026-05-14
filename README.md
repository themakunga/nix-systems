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
1. **Protected**


### CI/CD Pipelines

-

---

### Local Development


## español

---

### Descripcion

### Arquitectura y Functiones

### Flujo de Repositorio

### Pipelines CI/CD
