# Installation and deployment / Instalación y despliegue

[README](../README.md)

[English](#english) | [Español](#español)

## English

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

### Remote Linux hosts

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

### Raspberry Pi installers

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

## Español

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

Para desplegar Linux por SSH, consulta los destinos `make switch-*` y las opciones `TARGET_IP`, `APERTURE_IP` y `BUILD_HOST` de la sección anterior. Para activar macOS desde el checkout, consulta [Darwin](darwin.md#español).

### Instaladores Raspberry Pi

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
