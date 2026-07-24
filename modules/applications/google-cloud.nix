# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{self, ...}: let
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
        my.dotfiles.packages = ["gemini"];
        sops.secrets."applications/gemini/api-key" = {
          owner = username;
        };
        environment.interactiveShellInit = ''
          export GEMINI_API_KEY="$(cat ${config.sops.secrets."applications/gemini/api-key".path} 2>/dev/null)"
        '';
      };
    };

    gcloud = mkAppModule "gcloud" "Enable Google Cloud SDK" {
      meta = {pkgs, ...}: {
        level = "system";
        packages = [pkgs.google-cloud-sdk];
      };
    };
  };
}
