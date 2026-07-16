# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: disko-sd.nix
# Path: ./modules/modules/rpi/disko-sd.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.rpiModules.disko-sd = {
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/mmcblk0";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["defaults" "umask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = ["defaults"];
            };
          };
        };
      };
    };
  };
}
