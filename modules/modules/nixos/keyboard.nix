# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: keyboard.nix
# Path: ./modules/modules/nixos/keyboard.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{lib, ...}: {
  flake.nixosModules.keyboard = {config, ...}: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.keyboard;
  in {
    options.my.keyboard = {
      enable = mkEnableOption "NixOS keyboard config";
    };

    config = mkIf cfg.enable {
      console.keyMap = "us";

      services.xserver.xkb = {
        layout = "us,latam";
        options = "ctrl:nocaps,grp:win_space_toggle";
      };
    };
  };
}
