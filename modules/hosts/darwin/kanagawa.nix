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
  inherit (inputs) nix-darwin nix-homebrew sops-nix secrets mac-app-util;
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
        darwinModules = ["tiling"];
        applicationModules = ["google-cloud.gcloud"];
        developmentModules = ["ios-terminal"];
        userModules = ["personal"];
        profileModules = ["personal" "bbook" "company"];
      }))
      ++ [
        ({pkgs, ...}: {
          system.defaults.dock.persistent-apps = [
            "/Applications/WezTerm.app"
            "/Applications/Typora.app"
            "/Applications/Zen.app"
          ];
          my = {
            services.tiling.enable = true;
            packages = [pkgs.claude-code];
            hostSecrets.file = "${secrets.outPath}/hosts/kanagawa.yaml";

            wallpaper = {
              enable = true;
              path = "${self}/media/wp/kanagawa-fullsize.jpg";
              fileName = "kanagawa-fullsize.jpg";
            };

            casks = ["typora"];

            development = {
              containers = {
                useSecrets = false;
              };
              ios-terminal.enable = true;
            };
          };
        })
      ];
  };
}
