# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: default.nix
# Path: ./modules/modules/homeManager/default.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  inputs,
  globals,
  ...
}: let
  inherit (globals) stateVersion;
in {
  flake.homeManagerModules.common = {
    imports = [
      inputs.self.commonModules.home-secrets
    ];

    home = {
      stateVersion = stateVersion.home-manager;
      enableNixpkgsReleaseCheck = false;
    };

    programs = {
      home-manager.enable = true;
      git = {
        enable = true;
        settings.init.defaultBranch = "main";
      };
    };
  };
}
