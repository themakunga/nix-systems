# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.argocd
# =========================================================
{
  flake.developmentModules.argocd = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf optional;
    cfg = config.my.development.argocd;
  in {
    options.my.development.argocd = {
      enable = mkEnableOption "ArgoCD and GitOps development toolkit";

      enableAutopilot = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar ArgoCD Autopilot (herramienta oficial para bootstrapping de GitOps)";
      };

      useDotfiles = mkOption {
        type = types.bool;
        default = true;
        description = "Mapear configuración (ej. ~/.config/argocd) desde public-dotfiles";
      };

      useSecrets = mkOption {
        type = types.bool;
        default = false;
        description = "Cargar variables (ARGOCD_SERVER, ARGOCD_AUTH_TOKEN) desde SOPS";
      };
    };

    config = mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs;
          [
            argocd
          ]
          ++ optional cfg.enableAutopilot argocd-autopilot;

        interactiveShellInit = mkIf cfg.useSecrets ''
          if [ -f "${config.sops.secrets."development/argocd/env".path}" ]; then
            source "${config.sops.secrets."development/argocd/env".path}"
          fi
        '';
      };

      # Configuración Pública (Dotfiles vía Stow)
      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "argocd";
          isConfig = true; # Para que se vincule en ~/.config/argocd
        }
      ];

      # Configuración Sensible (SOPS)
      # Aquí puedes guardar cosas como:
      # export ARGOCD_SERVER="argocd.tu-empresa.com"
      # export ARGOCD_AUTH_TOKEN="ey..."
      sops.secrets."development/argocd/env" = mkIf cfg.useSecrets {};
    };
  };
}
