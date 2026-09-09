# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Hardware configuration for Raspberry Pi Zero 2W (BCM2710A1, 512 MB LPDDR2).
# Forces the correct DTB (bcm2710-rpi-zero-2-w.dtb) — do not combine with
# nixos-hardware.raspberry-pi-3, which selects a different DTB and conflicts.
# Enables zram swap to avoid SD card wear from a traditional swap partition.
{lib, ...}: {
  flake.rpiModules.hardware-rpi-zero2w = {modulesPath, ...}: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    hardware = {
      enableRedistributableFirmware = true;
      deviceTree = {
        enable = true;
        # En el kernel estándar upstream (linux-6.18+) el DTB usa el nombre
        # real del SoC (BCM2837), no el nombre de marketing (BCM2710).
        # El kernel RPi-específico usa bcm2710-*, el estándar usa bcm2837-*.
        filter = lib.mkForce "bcm2837-rpi-zero-2-w.dtb";
      };
    };

    zramSwap = {
      enable = lib.mkDefault true;
      memoryPercent = lib.mkDefault 50;
    };
  };
}
