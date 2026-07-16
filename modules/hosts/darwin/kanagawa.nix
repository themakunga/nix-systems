# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: kanagawa.nix
# Path: ./modules/hosts/darwin/kanagawa.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nix-darwin
    nix-homebrew
    home-manager
    sops-nix
    secrets
    ;
  inherit
    (self)
    commonModules
    userModules
    darwinModules
    profileModules
    applicationModules
    ;
in {
  flake.darwinConfigurations.kanagawa = nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "kanagawa";
    };

    modules = [
      sops-nix.darwinModules.sops
      nix-homebrew.darwinModules.nix-homebrew
      home-manager.darwinModules.home-manager

      commonModules.arch.darwin.silicon
      commonModules.settings
      commonModules.host-secrets
      commonModules.userProfiles
      commonModules.network
      commonModules.home-manager

      darwinModules.keyboard
      darwinModules.primaryUser
      darwinModules.security
      darwinModules.dock
      darwinModules.finder
      darwinModules.extras
      darwinModules.homebrew

      userModules.nicolas-personal

      profileModules.nicolas-personal
      profileModules.nicolas-42devs
      profileModules.nicolas-bbook

      applicationModules.tailscale
      {
        my = {
          hostSecrets.file = "${secrets.outPath}/hosts/kanagawa.yaml";
          tailscale = {
            enable = true;
            gui.enable = true;
          };
          primaryUser = {
            enable = true;
            username = "nicolas";
          };
          keyboard.enable = true;
        };
      }
    ];
  };
}
