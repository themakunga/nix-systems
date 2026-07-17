# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: openconnect.nix
# Path: ./modules/applications/openconnect.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{inputs, ...}: {
  flake.applicationModules.openconnect = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf;
    inherit (pkgs.stdenv.hostPlatform) system;

    cfg = config.my.openconnect;
  in {
    options.my.openconnect = {
      enable = mkEnableOption "OpenConnect and GlobalProtect clients";
    };

    config = mkIf cfg.enable {
      environment.systemPackages = [
        inputs.globalprotect-openconnect.package.${system}.default
        pkgs.openconnect
      ];
    };
  };
}
