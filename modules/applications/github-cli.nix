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
  flake.applicationModules.github-cli = mkAppModule "github-cli" "Enable GitHub CLI" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = with pkgs; [
        gh
        gama-tui # Alternative to lazyactions to monitor and manage GitHub Actions
      ];
    };
    sysConfig = {config, ...}: {
      sops.secrets."applications/gh/token" = {};
      environment.interactiveShellInit = ''
        export GH_TOKEN="$(cat ${config.sops.secrets."applications/gh/token".path} 2>/dev/null)"
      '';
      home-manager.sharedModules = [
        {
          xdg.configFile."gh" = {
            source = "${dotfiles}/gh";
            recursive = true;
            force = true;
          };
        }
      ];
    };
  };
}
