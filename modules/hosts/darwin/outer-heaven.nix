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
        mac-app-util.darwinModules.default
      ]
      ++ (mkBundle {
        commonModules = [
          "cloud-profiles"
          "dotfiles"
          "apps"
          "arch.darwin.silicon"
          "host-secrets"
          "network"
          "settings"
          "userProfiles"
          "home-secrets"
          "git-identity"
          "sops-gpg"
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
          "local-ai"
        ];
        userModules = [
          "nicolas-work"
          "glados"
        ];
        profileModules = [
          "nicolas-work"
          "nicolas-personal"
          "latam"
          "glados"
          "thoughtworks"
        ];
      })
      ++ [
        ({pkgs, ...}: {
          my = {
            dotfiles.enable = true;
            cloudProfiles = {
              aws = [
              ];
              gcp = [
                # "personal"
                # "latam"
              ];
            };
            hostSecrets.file = "${secrets.outPath}/hosts/outer-heaven.yaml";
            primaryUser = {
              enable = true;
              username = "nicolas";
            };
            keyboard.enable = true;
            apps = {
              aws-cli.enable = true;
              tailscale-core.enable = true;
              tailscale-gui.enable = true;
              neovim.enable = true;
              terminal-zsh.enable = true;
              github-cli.enable = true;
              gemini-cli.enable = true;
              gcloud.enable = true;
              ghostty.enable = true;
              halloy.enable = true;
              irssi.enable = true;
              nchat.enable = true;

              outer-heaven = {
                enable = true;
                level = "system";

                packages = with pkgs; [
                  stow
                  btop
                  ctop
                ];

                casks = [
                  "iterm2"
                  "logitech-g-hub"
                  "okta-verify"
                  "wezterm"
                  "zen"
                  "ghostty"
                ];

                masApps = {
                  "Amphetamine" = 937984704;
                  "Magnet" = 441258766;
                  "Xcode" = 497799835;
                };
              };
            };
            services.local-ai = {
              enable = true;
              cpuThreads = "10";
              maxVramBytes = "27917287424";
              parallelRequests = "4";
            };
          };
        })
      ];
  };
}
