# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Darwin host: kanagawa — personal MacBook Pro (Apple Silicon).
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

            # IP estática — Darwin 192.168.1.1x
            # Verificar servicio: networksetup -listallnetworkservices
            # Opciones comunes: "Wi-Fi", "Ethernet", "USB 10/100/1000 LAN"
            network.staticIP = {
              enable = true;
              address = "192.168.1.11";
              gateway = "192.168.1.1";
              interface = "Wi-Fi";
              extraInterfaces = ["Ethernet"]; # aplica en ambas conexiones
            };

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
              location = "Quebrada de macul, Chile";
              units = "c";
              forecast = ["d" "w"];
            };
            hostSecrets.file = "${secrets.outPath}/hosts/kanagawa.yaml";
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
            ];

            casks = [
              "iterm2"
              "wezterm"
              "zen"
              "ghostty"
              "reminders-menubar"
            ];

            masApps = {
              "Amphetamine" = 937984704;
              "Magnet" = 441258766;
              "Xcode" = 497799835;
            };

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
              golang.enable = true;
              rust.enable = true;
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
