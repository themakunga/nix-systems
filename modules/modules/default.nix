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
  inherit (types) attrsOf raw;
in {
  options = {
    flake = {
      applicationModules = mkOption {
        description = "custom apps config";
        type = attrsOf raw;
        default = {};
      };

      bundle = mkOption {
        description = "Bundle packages";
        type = attrsOf raw;
        default = {};
      };
      commonModules = mkOption {
        description = "Shared Modules accross differents systems";
        type = attrsOf raw;
        default = {};
      };
      darwinModules = mkOption {
        description = "Darwin Modules to use with Apple Sillicon products";
        type = attrsOf raw;
        default = {};
      };
      darwinConfigurations = mkOption {
        description = "Darwin main configurations";
        type = attrsOf raw;
        default = {};
      };
      rpiModules = mkOption {
        description = "Nixos aarch64-linux focused modules, to use exclusivelly
          with raspberry pi";
        type = attrsOf raw;
        default = {};
      };
      deviceModules = mkOption {
        description = "devices Modules";
        type = attrsOf raw;
        default = {};
      };
      profileModules = mkOption {
        description = "Profile Management";
        type = attrsOf raw;
        default = {};
      };
      userModules = mkOption {
        description = "User creation Modules";
        type = attrsOf raw;
        default = {};
      };
      lib = mkOption {
        description = "lib helpers for flakes";
        type = attrsOf raw;
        default = {};
      };
      developmentModules = mkOption {
        description = "Development tools and languages";
        type = attrsOf raw;
        default = {};
      };
    };
  };
  config = {};
}
