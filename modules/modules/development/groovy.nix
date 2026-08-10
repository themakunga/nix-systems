# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.groovy
# =========================================================
{
  flake.developmentModules.groovy = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf optional;
    cfg = config.my.development.groovy;
  in {
    options.my.development.groovy = {
      enable = mkEnableOption "Groovy development toolkit (Runtime, Jenkins/Gradle support)";

      enableGradle = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar Gradle (Muy utilizado en ecosistema Groovy)";
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
            groovy
          ]
          ++ optional cfg.enableGradle gradle
          ++ [
            # LSP y herramientas de código
            groovy-language-server
          ];

        # Groovy depende de Java. Aseguramos un entorno sano (opcional si ya usas java.nix, pero seguro aquí)
        variables = {
          GROOVY_HOME = "${pkgs.groovy}/groovy";
        };

        interactiveShellInit = mkIf cfg.useSecrets ''
          if [ -f "${config.sops.secrets."development/groovy/env".path}" ]; then
            source "${config.sops.secrets."development/groovy/env".path}"
          fi
        '';
      };

      # Configuración Pública
      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "groovy";
          isConfig = true;
        }
      ];

      # Configuración Sensible (Credenciales de Nexus, Artifactory, etc.)
      sops.secrets."development/groovy/env" = mkIf cfg.useSecrets {};
    };
  };
}
