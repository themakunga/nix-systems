# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: home-manager.nix
# Path: ./modules/modules/common/home-manager.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  self,
  inputs,
  ...
}: let
  inherit (self) commonModules homeManagerModules;
in {
  flake.commonModules.home-manager = {
    imports = [
      commonModules.sops.gpg
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {
        inherit inputs self;
      };

      sharedModules = [
        homeManagerModules.common
        inputs.mac-app-util.homeManagerModules.default
      ];
    };
  };
}
