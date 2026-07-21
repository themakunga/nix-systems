# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: gh.nix
# Path: ./modules/applications/gh.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  inputs,
  self,
  ...
}: let
  inherit (inputs) dotfiles;
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModule.github-cli =
    mkAppModule "github" "Enable GitHub CLI"
    ({config, ...}: {
      my.apps.github-cli = {
        level = "system";
        apps = ["gh"];
      };

      sops.secret."applications/gh/token" = {};

      environment.interactiveShellInit = ''
        export GH_TOKEN="$(cat
        ${config.sops.secrets."applications/gh/token".path} 2>/dev/null)"
      '';

      home-manager.sharedModules = [
        {
          xdg.configFile."gh" = {
            source = "${dotfiles}/gh";
            recursive = true;
          };
        }
      ];
    });
}
