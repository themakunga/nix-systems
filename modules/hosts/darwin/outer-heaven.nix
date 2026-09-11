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
  inherit (inputs) nix-darwin nix-homebrew sops-nix secrets mac-app-util;
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
        applicationModules = ["google-cloud.gemini" "ollama"];
        userModules = ["work" "glados"];
        profileModules = ["work" "personal" "latam" "glados" "thoughtworks"];
      }))
      ++ [
        ({pkgs, ...}: {
          my = {
            linux-builder.enable = true;
            hostSecrets.file = "${secrets.outPath}/hosts/outer-heaven.yaml";

            wallpaper = {
              enable = true;
              path = "${self}/media/wp/wallpaper-outer-heaven.jpg";
              fileName = "wallpaper-outer-heaven.jpg";
            };

            ollama = {
              enable = true;
              host = "127.0.0.1";
              openFirewall = false;
              models = ["qwen2.5-coder:7b"];
            };

            # work-only packages (stow/pre-commit/btop/ctop come from darwin-mac/personal profiles)
            packages = with pkgs; [
              terminal-notifier
              claude-code
              unstable.cliamp
              jdk25
              argo-workflows
              rustc
            ];

            casks = ["tigervnc" "okta-verify" "halloy" "miniconda" "claude-code"];

            apps = {
              aws-cli.enable = true;
              gemini-cli.enable = true;
            };
          };
        })
      ];
  };
}
