# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
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
    gemini = mkAppModule "gemini-cli" "Enable Gemini CLI and configure it" {
      meta = {pkgs, ...}: {
        level = "system";
        packages = [pkgs.gemini-cli];
      };
      sysConfig = {config, ...}: {
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
      };
    };

    gcloud = mkAppModule "gcloud" "Enable Google Cloud SDK" {
      meta = {pkgs, ...}: {
        level = "system";
        packages = [pkgs.google-cloud-sdk];
      };
      sysConfig = {
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
  };
}
