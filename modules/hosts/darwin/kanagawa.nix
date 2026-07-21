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
    mac-app-util
    ;
  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake.darwinConfigurations.kanagawa = nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "kanagawa";
    };

    modules =
      [
        sops-nix.darwinModules.sops
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager
        mac-app-util.darwinModules.default
      ]
      ++ (mkBundle {
        commonModules = [
          "apps"
          "arch.darwin.silicon"
          "home-manager"
          "host-secrets"
          "network"
          "settings"
          "userProfiles"
        ];
        darwinModules = [
          "extras"
          "finder"
          "homebrew"
          "keyboard"
          "primaryUser"
          "security"
        ];
        applicationModules = [
          "gh"
          "neovim"
          "tailscale.core"
          "terminal-zsh"
        ];
        userModules = [
          "nicolas-personal"
        ];
        profileModules = [
          "nicolas-personal"
          "nicolas-bbook"
          "nicolas-42devs"
        ];
      })
      ++ [
        {
          my = {
            hostSecrets.file = "${secrets.outPath}/hosts/kanagawa.yaml";
            primaryUser = {
              enable = true;
              username = "nicolas";
            };
            keyboard.enable = true;
            apps = {
              tailscale.enable = true;
            };
          };
        }
      ];
  };
}
