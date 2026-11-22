# Development and validation / Desarrollo y validación

[README](../README.md)

[English](#english) | [Español](#español)

## English

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

### Private CI inputs

Workflows pass the base64 SSH secret only to `scripts/setup-ci-ssh.sh`. The helper
loads it through stdin into an ephemeral SSH agent and exports only `SSH_AUTH_SOCK`
and `SSH_AGENT_PID`; it never writes the decoded private key to a file or job environment.
An always-run cleanup step stops the agent. Do not enable shell tracing around secret handling.

Run the regression checks without using production credentials:

```sh
python3 -m unittest discover -s tests -p test_ci_secret_handling.py
actionlint .github/workflows/*.yaml
```

If a private key appeared in an earlier log, revoke/replace that key, update
`SECRETS_REPO_SSH_KEY_BASE64`, and remove the affected workflow logs. This code change
does not revoke old credentials or remove historical logs.

### CI

`CI — Check & Dry-run` runs lint, flake evaluation and dry-runs
for the six Linux hosts on pushes and pull requests to `develop`. Lint resolves
`pre-commit`, Statix and Alejandra from the primary nixpkgs revision in `flake.lock`.
Its environment cache is keyed by both the hook configuration and lockfile, preventing
reuse across incompatible toolchain revisions. Security scanning runs separately.
CI checks and dry-runs do not activate any host.

## Español

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

### CI

Las herramientas de lint usan la revisión primaria de nixpkgs de `flake.lock`.
La caché incluye el archivo de bloqueo y la configuración de hooks. CI comprueba
formato, evaluación y dry-runs de los seis hosts Linux; seguridad se ejecuta aparte.

### Advertencias y dotfiles

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
