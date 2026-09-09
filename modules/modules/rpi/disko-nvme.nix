# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: disko-nvme.nix
# Path: ./modules/modules/rpi/disko-nvme.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.rpiModules.disko-nvme = {
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              # Label FIRMWARE: coincide con lo que nixos-hardware.raspberry-pi-5
              # genera en /etc/fstab (/dev/disk/by-label/FIRMWARE → /boot/firmware).
              # IMPORTANTE: el mountpoint DEBE ser /boot/firmware (no /boot).
              # nixos-hardware.raspberry-pi-5 declara fileSystems."/boot/firmware" → FIRMWARE,
              # y el bootloader instala los archivos ahí. Si se usa /boot, el EEPROM
              # no encuentra config.txt en la raíz de la partición FAT32 → error code 7.
              extraArgs = ["-n" "FIRMWARE"];
              mountpoint = "/boot/firmware";
              mountOptions = ["defaults" "umask=0077"];
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              # Label NIXOS_SD: coincide con lo que nixos-hardware.raspberry-pi-5
              # genera en /etc/fstab (/dev/disk/by-label/NIXOS_SD → /).
              # Sin este label el initramfs no encuentra la partición root.
              extraArgs = ["-L" "NIXOS_SD"];
              mountpoint = "/";
              mountOptions = ["defaults"];
            };
          };
        };
      };
    };
  };
}
