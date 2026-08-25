# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# SD image configuration for Raspberry Pi 3 and Zero 2W.
# Uses U-Boot via generic-extlinux-compatible. Wraps sd-image-aarch64.nix
# with a minimal initrd kernel module set and an ext4 root filesystem.
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
