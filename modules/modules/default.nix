# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Declares all custom flake output namespaces used across the module tree.
# flake-parts merges these options from every module that contributes values.
{lib, ...}: let
  inherit (lib) mkOption types;
  inherit (types) attrsOf raw;
in {
  options = {
    flake = {
      applicationModules = mkOption {
        description = "Application configuration modules";
        type = attrsOf raw;
        default = {};
      };

      bundle = mkOption {
        description = "Named module bundle specs (resolved by mkBundle)";
        type = attrsOf raw;
        default = {};
      };

      commonModules = mkOption {
        description = "Modules shared across NixOS and Darwin hosts";
        type = attrsOf raw;
        default = {};
      };

      darwinModules = mkOption {
        description = "macOS-specific modules (nix-darwin)";
        type = attrsOf raw;
        default = {};
      };

      darwinConfigurations = mkOption {
        description = "Darwin host configurations";
        type = attrsOf raw;
        default = {};
      };

      rpiModules = mkOption {
        description = "aarch64-linux modules for Raspberry Pi hosts";
        type = attrsOf raw;
        default = {};
      };

      deviceModules = mkOption {
        description = "Peripheral and device configuration modules";
        type = attrsOf raw;
        default = {};
      };

      profileModules = mkOption {
        description = "User profile and environment modules";
        type = attrsOf raw;
        default = {};
      };

      userModules = mkOption {
        description = "User account creation modules";
        type = attrsOf raw;
        default = {};
      };

      lib = mkOption {
        description = "Flake-level library helpers";
        type = attrsOf raw;
        default = {};
      };

      developmentModules = mkOption {
        description = "Development language and toolchain modules";
        type = attrsOf raw;
        default = {};
      };
    };
  };
  config = {};
}
