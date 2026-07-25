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
        mac-app-util.darwinModules.default
      ]
      ++ (mkBundle {
        commonModules = [
          "dotfiles"
          "apps"
          "arch.darwin.silicon"
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
          "google-cloud.gcloud"
          "neovim"
          "openconnect"
          "tailscale.core"
          "tailscale.gui"
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
        ({pkgs, ...}: {
          my = {
            dotfiles.enable = true;
            hostSecrets.file = "${secrets.outPath}/hosts/kanagawa.yaml";
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
              gcloud.enable = true;
              ghostty.enable = true;
              halloy.enable = true;
              irssi.enable = true;
              nchat.enable = true;

              kanagawa = {
                enable = true;
                level = "system";

                packages = [
                  pkgs.stow
                ];

                casks = [
                  "iterm2"
                  "logitech-g-hub"
                  "okta-verify"
                  "wezterm"
                  "zen"
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
