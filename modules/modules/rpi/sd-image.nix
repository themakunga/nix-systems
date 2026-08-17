# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: sd-image.nix
# Path: ./modules/modules/rpi/sd-image.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{inputs, ...}: let
  inherit (inputs) nixpkgs;
in {
  flake.rpiModules.sd-image = {lib, ...}: {
    imports = [
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];

    sdImage.compressImage = true;

    boot = {
      supportedFilesystems = lib.mkForce ["ext4" "vfat"];
      loader.generic-extlinux-compatible.enable = true;

      initrd = {
        includeDefaultModules = false;
        availableKernelModules = lib.mkForce [
          "usbhid"
          "usb_storage"
          "vc4"
          "mmc_block"
          "reset-raspberrypi"
        ];
      };
    };

    hardware = {
      deviceTree.enable = true;
      enableRedistributableFirmware = true;
    };

    fileSystems."/" = {
      device = lib.mkForce "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
}
