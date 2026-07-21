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
          "github-cli"
          "google-cloud.gemini"
          "neovim"
          "openconnect"
          "tailscale.core"
          "tailscale.gui"
          "terminal-zsh"
        ];
        userModules = [
          "nicolas-work"
        ];
        profileModules = [
          "nicolas-work"
          "thoughtworks"
        ];
      })
      ++ [
        ({pkgs, ...}: {
          my = {
            hostSecrets.file = "${secrets.outPath}/hosts/outer-heaven.yaml";
            primaryUser = {
              enable = true;
              username = "nicolas";
            };
            keyboard.enable = true;
            apps = {
              tailscale-core.enable = true;
              tailscale-gui.enable = true;
              neovim.enable = true;
              terminal-zsh.enable = true;
              github-cli.enable = true;
              gemini-cli.enable = true;

              outer-heaven = {
                enable = true;
                level = "system";

                packages = [
                  pkgs.stow
                  pkgs.tmux
                ];

                casks = [
                  "iterm2"
                  "logitech-g-hub"
                  "okta-verify"
                  "wezterm"
                ];

                masApps = {
                  "Amphetamine" = 937984704;
                  "Magnet" = 441258766;
                  "Xcode" = 497799835;
                };
              };
            };
          };
        })
      ];
  };
}
