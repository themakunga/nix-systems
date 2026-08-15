# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.swift
# =========================================================
{
  flake.developmentModules.swift = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf optional;
    cfg = config.my.development.swift;
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  in {
    options.my.development.swift = {
      enable = mkEnableOption "Swift & Apple platforms development toolkit";

      enableTuist = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar Tuist (Generador de proyectos de Xcode que optimiza tiempos de compilación y ejecución de tests)";
      };

      enableFastlane = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar Fastlane (Automatización de testing continuo y despliegue a TestFlight/App Store)";
      };

      useDotfiles = mkOption {
        type = types.bool;
        default = true;
      };

      useSecrets = mkOption {
        type = types.bool;
        default = false;
        description = "Cargar secretos de SOPS (Tokens de App Store Connect, Match Passwords, etc.)";
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs;
        [
          # Linters y Formatters (Fundamentales para NeoVim y CI/CD)
          swiftlint
          swiftformat

          # Gestores de Dependencias Legacy (Aún muy usados)
          cocoapods

          # Herramienta para gestionar versiones de Xcode desde la terminal
          xcodes
        ]
        ++ optional cfg.enableTuist tuist
        ++ optional cfg.enableFastlane fastlane;

      # Configuración Pública (Dotfiles vía Stow)
      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "swift";
          isConfig = false; # Para mapear reglas globales como ~/.swiftlint.yml
        }
      ];

      # Configuración Sensible (SOPS)
      sops.secrets."development/swift/env" = mkIf cfg.useSecrets {};

      environment.interactiveShellInit = mkIf cfg.useSecrets ''
        if [ -f "${config.sops.secrets."development/swift/env".path}" ]; then
          source "${config.sops.secrets."development/swift/env".path}"
        fi
      '';

      # Advertencia de seguridad en caso de que actives esto en un servidor Linux
      warnings =
        if (cfg.enable && !isDarwin)
        then [
          "El módulo my.development.swift está habilitado en un sistema Linux. Aunque algunas herramientas de Swift funcionan, el desarrollo para iOS/macOS requiere Darwin."
        ]
        else [];
    };
  };
}
