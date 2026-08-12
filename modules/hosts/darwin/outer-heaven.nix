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
          "devenv"
          "wallpaper"
          "weather"
        ];
        darwinModules = [
          "extras"
          "finder"
          "homebrew"
          "keyboard"
          "primaryUser"
          "security"
          "janitor"
        ];
        applicationModules = [
          "github-cli"
          "google-cloud.gemini"
          "neovim"
          "openconnect"
          "tailscale.core"
          "tailscale.gui"
          "terminal-zsh"
          "agents"
        ];
        deviceModules = [
          "audio"
          "logitech"
          "sony"
          "hyperx"
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
        developmentModules = [
          "argocd"
          "aws"
          "containers"
          "gcp"
          "golang"
          "groovy"
          "iac"
          "java"
          "nodejs"
          "python"
          "ruby"
          "rust"
          "swift"
        ];
      })
      ++ [
        ({pkgs, ...}: {
          my = {
            dotfiles.enable = true;
            devices = {
              audio.enable = true;
              logitech.enable = true;
              sony.enable = true;
              hyperx.enable = true;
            };
            wallpaper = {
              path = "${self}/media/wp/kanagawa-fullsize.jpg";
              enable = true;
              fileName = "kanagawa-fullsize.jpg";
            };
            weather = {
              enable = true;
              location = "Penalolen, Chile";
              units = "c";
              forecast = ["d" "w"];
            };
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
                  pre-commit
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

            development = {
              containers = {
                enable = true;
                runtime = "colima";
                kubernetes = true;
                argocd = false;
                useDotfiles = true;
                useSecrets = false;
                kubeconfigs = [
                  # "kubernetes/latam_config"
                ];
              };
              aws = {
                enable = true;
                enableSSM = true;
                enableLocalStack = true;
                useDotfiles = true;
                useSecrets = false;
              };
              gcp = {
                enable = true;
                enableGkePlugin = true;
                useDotfiles = false;
                useSecrets = false;
              };
              iac = {
                enable = true;
                enableOpenTofu = true;
                enableTerraform = false;
                enablePulumi = true;
                useDotfiles = true;
                useSecrets = false;
              };
              argocd = {
                enable = true;
                enableAutopilot = true;
                useDotfiles = true;
                useSecrets = false;
              };
              nodejs = {
                enable = true;
                package = pkgs.nodejs_24;
                packageManager = "pnpm";
                enableBun = true;
                enableGlobals = true;
                useDotfiles = true;
                useSecrets = false;
              };
              python = {
                enable = true;
                package = pkgs.python3;
                enablePoetry = true;
                useDotfiles = true;
                useSecrets = false;
              };
              golang = {
                enable = true;
                useDotfiles = true;
                useSecrets = false;
              };
              rust = {
                enable = true;
                useDotfiles = true;
                useSecrets = false;
              };
              java = {
                enable = true;
                jdk = pkgs.jdk21;
                enableMaven = true;
                enableGradle = true;
                useDotfiles = true;
                useSecrets = false;
              };
              ruby = {
                enable = true;
                package = pkgs.ruby;
                useDotfiles = true;
                useSecrets = false;
              };
              groovy = {
                enable = true;
                enableGradle = true;
                useDotfiles = true;
                useSecrets = false;
              };
              swift = {
                enable = true;
                enableTuist = true;
                enableFastlane = true;
                useDotfiles = true;
                useSecrets = false; # Fundamental
              };
            };

            tools = {
              devenv.enable = true;
            };
            agents = {
              claude.enable = true;
              codeen.enable = true;
              zeroclaw = {
                enable = false;
                # /* c */ores = 8; # Nix lo convertirá a la variable de entorno ZEROCLAW_CORES="8"
                # /* m */emory = "16G"; # ZEROCLAW_MEMORY="16G"
                # extraEnv = {
                #   ZEROCLAW_LOG_LEVEL = "debug";
                #   ZEROCLAW_OFFLOAD = "true";
                # };
              };
              ollama = {
                enable = false;
                # cores = 8; # OLLAMA_OMP_NUM_THREADS="8" (Controla CPU)
                # memory = "12G"; # OLLAMA_MAX_VRAM="12G" (Controla Memoria Máxima)
                # extraEnv = {
                #   OLLAMA_KEEP_ALIVE = "10m"; # Mantiene el modelo en memoria 10 mins después del último uso
                #   OLLAMA_HOST = "127.0.0.1:11434";
                # };
              };
            };
            services = {
              janitor = {
                enable = true;
                cleanCaches = true;
                emptyTrash = true;
                cleanXcode = true;
                cleanBrew = true;
                cleanNpm = true;
                cleanTerraform = true;
                cleanGolang = true;
                cleanJava = true;
                cleanPython = true;
                cleanNix = true;
              };
            };
          };
        })
      ];
  };
}
