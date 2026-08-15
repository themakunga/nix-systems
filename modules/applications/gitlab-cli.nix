# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.gitlab-cli = mkAppModule "gitlab-cli" "Enable GitLab CLI" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = with pkgs; [
        glab
      ];
    };
    sysConfig = {config, ...}: {
      my.dotfiles.packages = [
        {
          name = "glab";
          isConfig = true;
        }
      ];

      sops.secrets."applications/glab/token" = {};

      environment.interactiveShellInit = ''
        export GITLAB_TOKEN="$(cat ${config.sops.secrets."applications/glab/token".path} 2>/dev/null)"
      '';
    };
  };
}
