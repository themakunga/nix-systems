# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: sd-image-rpi5.nix
# Path: ./modules/modules/rpi/sd-image-rpi5.nix
# Description: Imagen SD para Raspberry Pi 5.
#
#   El Pi 5 usa su propio EEPROM como bootloader (no U-Boot).
#   Este módulo reemplaza los comandos de firmware del módulo
#   genérico sd-image-aarch64.nix para usar arranque directo
#   via EEPROM, evitando la pantalla negra que produce U-Boot
#   de RPi4 en el Pi 5.
#
#   Usar junto a rpiModules.hardware-rpi5.
#   NO combinar con rpiModules.sd-image (ese es para Pi 3/Zero 2W).
# =====================
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
      # Provee la infraestructura de particionado (FAT32 boot + ext4 root)
      # Sobreescribimos populateFirmwareCommands para eliminar U-Boot
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];

    boot = {
      supportedFilesystems = lib.mkForce ["ext4" "vfat"];

      # El Pi 5 lee config.txt directamente desde el EEPROM
      # y carga el kernel sin pasar por extlinux
      loader.generic-extlinux-compatible.enable = lib.mkForce false;

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
      # El Pi 5 requiere más espacio en la partición boot para
      # el firmware, DTBs y kernel
      firmwareSize = 256;

      # Reemplaza completamente la lógica U-Boot del módulo base.
      # El Pi 5 EEPROM carga el kernel directamente via config.txt.
      populateFirmwareCommands = lib.mkForce ''
                mkdir -p firmware

                # ── Firmware base (start*.elf, fixup*.dat) ────────────────────
                (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && \
                  cp bootcode.bin fixup*.dat start*.elf \
                  $NIX_BUILD_TOP/firmware/ 2>/dev/null || true)
                chmod -R +w firmware/

                # ── DTBs desde el kernel compilado ────────────────────────────
                cp -r ${config.system.build.toplevel}/dtbs/broadcom/* \
                  firmware/ 2>/dev/null || true
                cp -r ${config.system.build.toplevel}/dtbs/* \
                  firmware/ 2>/dev/null || true

                # ── Overlays de firmware ──────────────────────────────────────
                mkdir -p firmware/overlays
                cp -r ${pkgs.raspberrypifw}/share/raspberrypi/boot/overlays/. \
                  firmware/overlays/
                chmod -R +w firmware/overlays/

                # ── Kernel e initrd ───────────────────────────────────────────
                # Extensión .img: el EEPROM del Pi 5 los carga directamente
                cp ${config.system.build.toplevel}/kernel firmware/kernel-pi5.img
                cp ${config.system.build.toplevel}/initrd firmware/initrd-pi5.img

                # ── cmdline.txt ───────────────────────────────────────────────
                echo "root=LABEL=NIXOS_SD rootfstype=ext4 rootwait \
        console=ttyAMA10,115200 console=tty0 \
        init=${config.system.build.toplevel}/init" \
                  > firmware/cmdline.txt

                # ── config.txt ────────────────────────────────────────────────
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
