# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: outer-heaven.nix
# Path: ./modules/hosts/darwin/outer-heaven.nix
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
  mkBundle = import ../lib/mkBundle.nix;
in {
  flake.darwinConfigurations.outer-heaven = nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "outer-heaven";
    };

    modules = [
      sops-nix.darwinModules.sops
      nix-homebrew.darwinModules.nix-homebrew
      home-manager.darwinModules.home-manager
      mac-app-util.darwinModules.default

      (mkBundle {
        commonModules = [
          "arch.darwin"
          "settings"
          "host-secrets"
          "userProfiles"
          "network"
          "app-helpers"
        ];
        darwinModules = [
          "primaryUser"
          "keyboard"
          "security"
          "finder"
          "extras"
          "homebrew"
          "docker" # TODO: change to applicationModule soon
        ];
        applicationModules = [
          "apps"
          "tailscale"
          "gh"
          "openconnect"
          "neovim"
          "terminal-zsh"
        ];
        userModules = [
          "nicolas-work"
        ];
        profileModules = [
          "nicolas-work"
          "thougthworks"
        ];
      })
      {
        my = {
          hostSecrets.file = "${secrets.outPath}/hosts/outer-heaven.yaml";
          tailscale = {
            enable = true;
            gui.enable = true;
          };
          primaryUser = {
            enable = true;
            username = "nicolas";
          };
          keyboard.enable = true;
          apps = {
            neovim.enable = true;
            terminal.enable = true;
            outer-heaven = {
              enable = true;
              level = "system";
              apps = [
                "Amphetamine"
                "Magnet"
                "Xcode"
                "iterm2"
                "logitech-g-hub"
                "okta-verify"
                "stow"
                "tmux"
                "wezterm"
              ];
            };
          };
        };
      }
    ];
  };
}
