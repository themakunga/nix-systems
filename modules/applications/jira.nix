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
    sysConfig = _: {
      # Secret declared in thoughtworks.nix (home-manager context) — system-level
      # sops-nix does not activate on macOS. Path resolves to home-manager secret.
      environment.interactiveShellInit = ''
        export JIRA_API_TOKEN="$(cat "$HOME/.config/sops-nix/secrets/applications/jira/token" 2>/dev/null)"
      '';
    };
  };
}
