# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: common.nix
# Path: ./modules/modules/rpi/common.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.rpiModules.common = {pkgs, ...}: {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    documentation = {
      enable = false;
      nixos.enable = false;
    };

    services.openssh.enable = true;

    environment.systemPackages = with pkgs; [
      git
      curl
      disko
      pciurils
    ];

    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = false;
    };
  };
}
