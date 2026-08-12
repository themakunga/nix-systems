# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.aws
# =========================================================
{
  flake.developmentModules.aws = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf optional optionalString;
    cfg = config.my.development.aws;
  in {
    options.my.development.aws = {
      enable = mkEnableOption "AWS Cloud development toolkit (CLI, SSM, CloudFormation tools)";

      enableSSM = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar Session Manager Plugin (para conectarse a instancias EC2 sin SSH port abierto)";
      };

      enableLocalStack = mkOption {
        type = types.bool;
        default = false;
        description = "Habilitar awslocal CLI para interactuar con LocalStack (AWS mock local)";
      };

      useDotfiles = mkOption {
        type = types.bool;
        default = true;
        description = "Mapear configuración pública (ej. ~/.aws/config base o aliases) desde public-dotfiles";
      };

      useSecrets = mkOption {
        type = types.bool;
        default = false;
        description = "Cargar variables de entorno dinámicas desde SOPS (Nota: las credenciales base ya las maneja my.cloudProfiles)";
      };
    };

    config = mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs;
          [
            # CLI Core
            awscli2

            # Linter para CloudFormation (Soporte para NeoVim)
            python3Packages.cfn-lint
          ]
          ++ optional cfg.enableSSM ssm-session-manager-plugin
          ++ optional cfg.enableLocalStack localstack;

        interactiveShellInit = ''
          ${optionalString cfg.useSecrets ''
            if [ -f "${config.sops.secrets."development/aws/env".path}" ]; then
              source "${config.sops.secrets."development/aws/env".path}"
            fi
          ''}

          ${optionalString cfg.enableLocalStack ''
            # Emulamos el comportamiento de awslocal de forma nativa
            alias awslocal="aws --endpoint-url=http://localhost:4566"
          ''}
        '';
      };

      # Configuración Pública (Dotfiles vía Stow)
      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "aws";
          isConfig = false; # Mapea directo a ~/ (útil si guardas aliases o plugins)
        }
      ];

      # Configuración Sensible (SOPS)
      sops.secrets."development/aws/env" = mkIf cfg.useSecrets {};
    };
  };
}
