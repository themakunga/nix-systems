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
      sysConfig = {
        config,
        options,
        ...
      }: let
        isDarwin = options ? system.darwin;
        username =
          if isDarwin
          then config.my.primaryUser.username
          else "nicolas";
      in {
        sops.secrets."applications/gemini/api-key" = {
          owner = username;
        };
        environment.interactiveShellInit = ''
          export GEMINI_API_KEY="$(cat ${config.sops.secrets."applications/gemini/api-key".path} 2>/dev/null)"
        '';
        home-manager.sharedModules = [
          {
            home.file.".gemini/config.yaml" = {
              source = "${dotfiles}/gemini/config.yaml";
              force = true;
            };
            home.file.".gemini/hooks" = {
              source = "${dotfiles}/gemini/hooks";
              recursive = true;
              force = true;
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
              force = true;
            };
          }
        ];
      };
    };
  };
}
