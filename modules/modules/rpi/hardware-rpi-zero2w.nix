# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: hardware-rpi-zero2w.nix
# Path: ./modules/modules/rpi/hardware-rpi-zero2w.nix
# Description: Hardware específico para Raspberry Pi Zero 2W.
#
#   SoC: BCM2710A1 (ARM Cortex-A53 quad-core, mismo die que RPi 3
#        pero en package distinto)
#   RAM: 512 MB LPDDR2
#   DTB: bcm2710-rpi-zero-2-w.dtb
#
#   Usar junto a rpiModules.sd-image (U-Boot, compatible con Pi Zero 2W).
#   NO usar nixos-hardware.nixosModules.raspberry-pi-3 junto a este
#   módulo: filtran DTBs diferentes y entran en conflicto.
# =====================
{lib, ...}: {
  flake.rpiModules.hardware-rpi-zero2w = {modulesPath, ...}: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    hardware = {
      enableRedistributableFirmware = true;
      deviceTree = {
        enable = true;
        # BCM2710A1: sin este filtro el bootloader carga el DTB genérico
        # del RPi 3 (bcm2837-rpi-3-b.dtb) y el hardware no inicia correctamente
        filter = lib.mkForce "bcm2710-rpi-zero-2-w.dtb";
      };
    };

    # ZRAM compensa la memoria limitada sin necesitar swap en SD
    # (escribir swap en SD card degrada la tarjeta rápidamente)
    # Usar mkDefault: el host puede sobreescribir si necesita más/menos
    zramSwap = {
      enable = lib.mkDefault true;
      memoryPercent = lib.mkDefault 50;
    };
  };
}
