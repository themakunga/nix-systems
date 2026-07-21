# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  inputs,
  self,
  ...
}: let
  inherit (inputs) dotfiles;
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.google-cloud = {
    gemini = mkAppModule "gemini-cli" "Enable Gemini CLI and configure it" ({config, ...}: {
      my.apps.gemini-cli = {
        level = "system";
        apps = ["gemini-cli"];
      };

      sops.secrets."applications/gemini/api-key" = {};

      environment.interactiveShellInit = ''
        export GEMINI_API_KEY="$(cat ${config.sops.secrets."applications/gemini/api-key".path} 2>/dev/null)"
      '';

      home-manager.sharedModules = [
        {
          xdg.configFile."gemini" = {
            source = "${dotfiles}/gemini";
            recursive = true;
          };
        }
      ];
    });
    gcloud = mkAppModule "gcloud" "Enable Google Cloud SDK" {
      my.apps.gcloud = {
        level = "system";
        apps = ["google-cloud-sdk"];
      };

      home-manager.sharedModules = [
        {
          xdg.configFile."gcloud" = {
            source = "${dotfiles}/gcloud";
            recursive = true;
          };
        }
      ];
    };
  };
}
