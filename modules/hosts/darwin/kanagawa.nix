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
  extendBundle = self.lib.extendBundle;
  bundles = self.bundle;
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
      ++ (mkBundle (extendBundle bundles.darwin.base {
        applicationModules = ["google-cloud.gcloud"];
        developmentModules = ["ios-terminal"];
        userModules = ["personal"];
        profileModules = ["personal" "bbook" "company"];
      }))
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
            # cloudProfiles = {
            #   aws = [
            #   ];
            #   gcp = [
            #     # "personal"
            #     # "latam"
            #   ];
            # };

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

                packages = with pkgs; [
                  stow
                  btop
                  ctop
                  pre-commit
                ];

                casks = [
                  "iterm2"
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
              ios-terminal.enable = true;
            };

            tools = {
              devenv.enable = true;
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
