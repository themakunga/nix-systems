# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: default.nix
# Path: ./modules/modules/default.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options = {
    flake = {
      applicationModules = mkOption {
        description = "custom apps config";
        type = types.attrsOf types.raw;
        default = {};
      };
      commonModules = mkOption {
        description = "Shared Modules accross differents systems";
        type = types.attrsOf types.raw;
        default = {};
      };
      darwinModules = mkOption {
        description = "Darwin Modules to use with Apple Sillicon products";
        type = types.attrsOf types.raw;
        default = {};
      };
      darwinConfigurations = mkOption {
        description = "Darwin main configurations";
        type = types.attrsOf types.raw;
        default = {};
      };
      rpiModules = mkOption {
        description = "Nixos aarch64-linux focused modules, to use exclusivelly
          with raspberry pi";
        type = types.attrsOf types.raw;
        default = {};
      };
      deviceModules = mkOption {
        description = "devices Modules";
        type = types.attrsOf types.raw;
        default = {};
      };
      profileModules = mkOption {
        description = "Profile Management";
        type = types.attrsOf types.raw;
        default = {};
      };
      userModules = mkOption {
        description = "User creation Modules";
        type = types.attrsOf types.raw;
        default = {};
      };
      lib = mkOption {
        description = "lib helpers for flakes";
        type = types.attrsOf types.raw;
        default = {};
      };
    };
  };
  config = {};
}
