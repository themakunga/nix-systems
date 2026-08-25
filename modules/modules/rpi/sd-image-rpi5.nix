# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# SD image configuration for Raspberry Pi 5 (EEPROM direct boot, no U-Boot).
# The Pi 5 EEPROM reads config.txt from the FAT32 partition and loads the kernel
# directly. populateFirmwareCommands replaces the sd-image-aarch64.nix default
# with a Pi 5-specific firmware layout (DTBs, kernel-pi5.img, config.txt).
#
# generic-extlinux-compatible is intentionally left enabled: disabling it makes
# populateCmd undefined, and mergeDefinitions evaluates all definitions during
# normalization — including the aarch64 one that references populateCmd — even
# when our mkForce definition has higher priority. populateRootCommands is
# overridden to skip calling populateCmd; the Pi 5 EEPROM ignores extlinux.
{inputs, ...}: let
  inherit (inputs) nixpkgs;
in {
  flake.rpiModules.sd-image-rpi5 = {
    lib,
    config,
    pkgs,
    ...
  }: {
    imports = [
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];

    boot = {
      supportedFilesystems = lib.mkForce ["ext4" "vfat"];

      initrd = {
        includeDefaultModules = false;
        availableKernelModules = lib.mkForce [
          "usbhid"
          "usb_storage"
          "xhci_pci"
          "nvme"
          "pcie_brcmstb"
          "reset-raspberrypi"
          "mmc_block"
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

    sdImage = {
      compressImage = true;
      firmwareSize = 256;

      populateRootCommands = lib.mkForce ''
        mkdir -p ./files/boot
      '';

      populateFirmwareCommands = lib.mkForce ''
        mkdir -p firmware

        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && \
          cp bootcode.bin fixup*.dat start*.elf \
          $NIX_BUILD_TOP/firmware/ 2>/dev/null || true)
        chmod -R +w firmware/

        cp -r ${config.system.build.toplevel}/dtbs/broadcom/* \
          firmware/ 2>/dev/null || true
        cp -r ${config.system.build.toplevel}/dtbs/* \
          firmware/ 2>/dev/null || true

        mkdir -p firmware/overlays
        cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays/. \
          firmware/overlays/
        chmod -R +w firmware/overlays/

        cp ${config.system.build.toplevel}/kernel firmware/kernel-pi5.img
        cp ${config.system.build.toplevel}/initrd firmware/initrd-pi5.img

        echo "root=LABEL=NIXOS_SD rootfstype=ext4 rootwait \
          console=ttyAMA10,115200 console=tty0 \
          init=${config.system.build.toplevel}/init" \
          > firmware/cmdline.txt

        cat > firmware/config.txt <<'CONFIGEOF'
        [pi5]
        kernel=kernel-pi5.img
        initramfs initrd-pi5.img followkernel
        dtparam=pciex1_gen=3
        dtoverlay=vc4-kms-v3d-pi5

        [all]
        arm_64bit=1
        enable_uart=1
        avoid_warnings=1
        CONFIGEOF
      '';
    };
  };
}
