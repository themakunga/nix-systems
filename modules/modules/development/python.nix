# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.python
# =========================================================
{
  flake.developmentModules.python = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf optional;
    cfg = config.my.development.python;
  in {
    options.my.development.python = {
      enable = mkEnableOption "Python 3 development toolkit (Runtime, LSP, Linters, Tools)";

      package = mkOption {
        type = types.package;
        default = pkgs.python3;
        description = "Versión de Python a utilizar (ej. pkgs.python311, pkgs.python312)";
      };

      enablePoetry = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar Poetry para gestión de dependencias y entornos virtuales";
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
        systemPackages = with pkgs;
          [
            # Runtime base
            cfg.package

            # Herramientas del Ecosistema
            python3Packages.pip
            python3Packages.virtualenv
          ]
          ++ optional cfg.enablePoetry poetry
          ++ [
            # LSPs (Language Servers)
            pyright # Type checker y LSP de Microsoft
            # ruff-lsp   # (Opcional, Ruff ya incluye LSP nativo en versiones recientes)

            # Linters y Formatters ultrarrápidos
            ruff # Reemplaza flake8, isort y black
            black # Formatter clásico por excelencia
          ];
        interactiveShellInit = mkIf cfg.useSecrets ''
          if [ -f "${config.sops.secrets."development/python/env".path}" ]; then
            source "${config.sops.secrets."development/python/env".path}"
          fi
        '';
      };

      # Configuración Pública (Dotfiles vía Stow)
      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "python";
          isConfig = true;
        }
      ];

      # Configuración Sensible (SOPS)
      sops.secrets."development/python/env" = mkIf cfg.useSecrets {};
    };
  };
}
