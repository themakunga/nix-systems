# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.jira = mkAppModule "jira" "Jira CLI tools (jira-cli-go + lazyjira)" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [
        pkgs.jira-cli-go
        inputs.lazyjira.packages.${pkgs.system}.lazyjira
      ];
    };
    sysConfig = {config, ...}: {
      sops.secrets."applications/jira/token" = {};
      environment.interactiveShellInit = ''
        export JIRA_API_TOKEN="$(cat ${config.sops.secrets."applications/jira/token".path} 2>/dev/null)"
      '';
    };
  };
}
