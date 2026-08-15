# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.gcp
# =========================================================
{
  flake.developmentModules.gcp = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.development.gcp;
  in {
    options.my.development.gcp = {
      enable = mkEnableOption "Google Cloud development toolkit (gcloud, GKE plugins)";

      enableGkePlugin = mkOption {
        type = types.bool;
        default = true;
        description = "Instalar plugin de autenticación para Google Kubernetes Engine (Requerido en GKE moderno)";
      };

      useDotfiles = mkOption {
        type = types.bool;
        default = true;
      };
      useSecrets = mkOption {
        type = types.bool;
        default = false;
      };
    };

    config = mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs; [
          # Usamos google-cloud-sdk con componentes adicionales de ser necesario
          (
            if cfg.enableGkePlugin
            then google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin]
            else google-cloud-sdk
          )
        ];
        interactiveShellInit = mkIf cfg.useSecrets ''
          if [ -f "${config.sops.secrets."development/gcp/env".path}" ]; then
            source "${config.sops.secrets."development/gcp/env".path}"
          fi
        '';
      };

      # Configuración Pública (Dotfiles vía Stow)
      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "gcp";
          isConfig = true; # Para enlazar en ~/.config/gcloud
        }
      ];

      # Configuración Sensible (SOPS)
      sops.secrets."development/gcp/env" = mkIf cfg.useSecrets {};
    };
  };
}
