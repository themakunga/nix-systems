# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.developmentModules.golang = {
    lib,
    pkgs,
    config,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkOption types;
    cfg = config.my.development.golang;
  in {
    options.my.development.golang = {
      enable = mkEnableOption "Golan development tools";

      useDotfiles = mkOption {
        type = types.bool;
        default = false;
        description = "Mapping config with dotfiles";
      };

      useSecrets = mkOption {
        type = types.bool;
        default = false;
        description = "Load config from secrets files";
      };
    };
    config = mkIf cfg.enable {
      sops.secrets."development/golang/env" = mkIf cfg.useSecrets {};

      environment = {
        systemPackages = with pkgs; [
          go
          gopls
          golangci-lint
          gotools
          delve
        ];

        interactiveShellInit = mkIf cfg.useSecrets ''
          if [ -f "${config.sops.secrets."development/golang/env".path}" ]; then
            source "${config.sops.secrets."development/golang/env".path}"
          fi
        '';
      };

      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "golang";
          isConfig = true;
        }
      ];
    };
  };
}
