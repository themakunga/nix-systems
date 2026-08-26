# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Darwin host: outer-heaven — work MacBook Pro (Apple Silicon).
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
      ++ (mkBundle (extendBundle bundles.darwin.base {
        commonModules = ["cloud-profiles"];
        darwinModules = ["linux-builder" "tiling"];
        applicationModules = ["google-cloud.gemini"];
        userModules = ["work" "glados"];
        profileModules = ["work" "personal" "latam" "glados" "thoughtworks"];
      }))
      ++ [
        ({pkgs, ...}: {
          my = {
            dotfiles.enable = true;
            linux-builder.enable = true;
            devices = {
              audio.enable = true;
              logitech.enable = true;
              sony.enable = true;
              hyperx.enable = true;
            };
            wallpaper = {
              path = "${self}/media/wp/wallpaper-outer-heaven.jpg";
              enable = true;
              fileName = "wallpaper-outer-heaven.jpg";
            };
            weather = {
              enable = true;
              location = "Quebrada de Macul, Chile";
              units = "c";
              forecast = ["d" "w"];
            };
            cloudProfiles = {
              aws = [
              ];
              gcp = [
              ];
            };
            hostSecrets.file = "${secrets.outPath}/hosts/outer-heaven.yaml";
            primaryUser = {
              enable = true;
              username = "nicolas";
            };
            keyboard.enable = true;
            packages = with pkgs; [
              stow
              btop
              ctop
              pre-commit
              terminal-notifier
              claude-code
              unstable.nchat
              jdk25
              unstable.cliamp
            ];

            casks = [
              "iterm2"
              "okta-verify"
              "wezterm"
              "zen"
              "ghostty"
              "miniconda"
              "halloy"
            ];

            masApps = {
              "Amphetamine" = 937984704;
              "Magnet" = 441258766;
              "Xcode" = 497799835;
            };

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
            };

            development = {
              containers = {
                enable = true;
                runtime = "colima";
                kubernetes = true;
                argocd = false;

                kubeconfigs = [
                ];
              };
              aws = {
                enable = true;
                enableSSM = true;
                enableLocalStack = true;
              };
              gcp = {
                enable = true;
                enableGkePlugin = true;
              };
              iac = {
                enable = true;
                enableOpenTofu = true;
                enableTerraform = false;
                enablePulumi = true;
              };
              argocd = {
                enable = true;
                enableAutopilot = true;
              };
              nodejs = {
                enable = true;
                package = pkgs.nodejs_24;
                packageManager = "pnpm";
                enableBun = true;
                enableGlobals = true;
              };
              python = {
                enable = true;
                package = pkgs.python3;
                enablePoetry = true;
              };
              golang = {
                enable = true;
              };
              rust = {
                enable = true;
              };
              java = {
                enable = true;
                jdk = pkgs.jdk21;
                enableMaven = true;
                enableGradle = true;
              };
              ruby = {
                enable = true;
                package = pkgs.ruby;
              };
              groovy = {
                enable = true;
                enableGradle = true;
              };
              swift = {
                enable = true;
                enableTuist = true;
                enableFastlane = true;
              };
            };

            tools = {
              devenv.enable = true;
            };
            services = {
              tiling.enable = false;
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
