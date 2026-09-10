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
        applicationModules = ["google-cloud.gcloud"];
        developmentModules = ["ios-terminal"];
        userModules = ["personal"];
        profileModules = ["personal" "bbook" "company"];
      }))
      ++ [
        (_: {
          my = {
            hostSecrets.file = "${secrets.outPath}/hosts/kanagawa.yaml";

            wallpaper = {
              enable = true;
              path = "${self}/media/wp/kanagawa-fullsize.jpg";
              fileName = "kanagawa-fullsize.jpg";
            };

            casks = ["vnc-viewer"]; # Cliente VNC — conectar a aperture-science:5900

            development = {
              containers = {
                useDotfiles = true;
                useSecrets = false;
              };
              ios-terminal.enable = true;
            };
          };
        })
      ];
  };
}
