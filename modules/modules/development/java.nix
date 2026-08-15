# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.java
# =========================================================
{
  flake.developmentModules.java = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf optional;
    cfg = config.my.development.java;
  in {
    options.my.development.java = {
      enable = mkEnableOption "Java development toolkit (JDK, LSP, Build Tools)";

      jdk = mkOption {
        type = types.package;
        default = pkgs.jdk21;
        description = "Versión del Java Development Kit (ej. pkgs.jdk17, pkgs.jdk21)";
      };

      enableMaven = mkOption {
        type = types.bool;
        default = true;
      };
      enableGradle = mkOption {
        type = types.bool;
        default = true;
      };

      useDotfiles = mkOption {
        type = types.bool;
        default = true;
        description = "Mapear configuraciones públicas (ej. formatter styles)";
      };

      useSecrets = mkOption {
        type = types.bool;
        default = false;
        description = "Cargar credenciales de repositorios (Artifactory/Nexus) desde SOPS";
      };
    };

    config = mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs;
          [
            # Runtime y Compilador
            cfg.jdk

            # Build Tools
          ]
          ++ optional cfg.enableMaven maven
          ++ optional cfg.enableGradle gradle
          ++ [
            # LSP (Language Server)
            jdt-language-server

            # Linters y Formatters
            google-java-format
            checkstyle
          ];

        # Setup de la variable JAVA_HOME
        variables = {
          JAVA_HOME = "${cfg.jdk}/lib/openjdk";
        };

        interactiveShellInit = mkIf cfg.useSecrets ''
          if [ -f "${config.sops.secrets."development/java/env".path}" ]; then
            source "${config.sops.secrets."development/java/env".path}"
          fi
        '';
      };

      # Configuración Pública (Dotfiles vía Stow)
      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "java";
          isConfig = false; # Ej. para ~/.m2 público
        }
      ];

      # Configuración Sensible (SOPS)
      sops.secrets."development/java/env" = mkIf cfg.useSecrets {};
    };
  };
}
