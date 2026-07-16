# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: boot-loader.nix
# Path: ./modules/modules/nixos/boot-loader.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.nixosModules.boot-loader = {
    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = false;
    };
  };
}
