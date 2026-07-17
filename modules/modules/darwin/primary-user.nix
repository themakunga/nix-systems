# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: primary-user.nix
# Path: ./modules/modules/darwin/primary-user.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{lib, ...}: {
  flake.darwinModules.primaryUser = {config, ...}: let
    inherit (lib) types mkEnableOption mkOption mkIf;
    cfg = config.my.primaryUser;
  in {
    options.my.primaryUser = {
      enable = mkEnableOption "Define primeary USER for dariwn host";
      username = mkOption {
        type = types.str;
        description = "main username to asign";
      };
    };

    config = mkIf cfg.enable {
      system.primaryUser = cfg.username;
    };
  };
}
