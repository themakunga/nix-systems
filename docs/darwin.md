# Darwin / macOS

[README](../README.md)

[English](#english) | [Español](#español)

## English

### Apply the host configuration

Successful Mac App Store operations report `OK: <app>`;
already-installed chatter is suppressed. With `my.devices.audio.enable`, audio selects `HyperX QuadCast` as input and
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

### Containers

For Podman startup, Docker compatibility and troubleshooting, see the Spanish operational notes below.

## Español

### Activación

MAS muestra `OK: nombre` cuando termina correctamente.
`my.devices.audio.enable` selecciona HyperX QuadCast y head radio solo si están
presentes. Los dispositivos ausentes son silenciosos; los errores reales conservan
su diagnóstico. Los cuatro destinos Mac usan `sudo -H` para el perfil y la activación.

La configuración declarada requiere activación para aplicarse. `make switch-kanagawa` y `make switch-outer-heaven` construyen y
activan el sistema completo, y ejecutan `git add -A`: revisa los cambios pendientes
antes de usarlos. El aviso de Git sucio permanece mientras haya archivos sin commit.
Las comprobaciones de MAS y audio no instalan aplicaciones ni cambian dispositivos:

```sh
python3 scripts/check-mas-activation.py
python3 scripts/check-quiet-activation.py
```

### Contenedores con Podman

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
