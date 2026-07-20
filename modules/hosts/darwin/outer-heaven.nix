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

  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
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
        ];
        darwinModules = [
          "primaryUser"
          "keyboard"
          "security"
          "finder"
          "extras"
          "homebrew"
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
          "thoughtworks" # CORREGIDO (typo)
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
            terminal-zsh.enable = true; # CORREGIDO (coincide con tu módulo)
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
