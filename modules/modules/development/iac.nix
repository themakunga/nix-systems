# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.iac
# =========================================================
{
  flake.developmentModules.iac = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf optional;
    cfg = config.my.development.iac;
  in {
    options.my.development.iac = {
      enable = mkEnableOption "Infrastructure as Code toolkit (Terraform, OpenTofu, Pulumi)";

      enableTerraform = mkOption {
        type = types.bool;
        default = false; # Falso por defecto hoy en día, ya que OpenTofu es el reemplazo libre
        description = "Habilitar HashiCorp Terraform";
      };

      enableOpenTofu = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar OpenTofu (Drop-in replacement open-source para Terraform)";
      };

      enablePulumi = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar Pulumi CLI";
      };

      useDotfiles = mkOption {
        type = types.bool;
        default = true;
        description = "Mapear configuraciones públicas (ej. .tflint.hcl o aliases) desde public-dotfiles";
      };

      useSecrets = mkOption {
        type = types.bool;
        default = false;
        description = "Cargar tokens sensibles (ej. PULUMI_ACCESS_TOKEN o TF_VAR_*) desde SOPS";
      };
    };

    config = mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs;
          [
            terraform-ls # Language Server
            tflint # Linter de buenas prácticas
            tfsec # Análisis de seguridad estático
          ]
          ++ optional cfg.enableTerraform terraform
          ++ optional cfg.enableOpenTofu opentofu
          ++ optional cfg.enablePulumi pulumi;

        interactiveShellInit = mkIf cfg.useSecrets ''
          if [ -f "${config.sops.secrets."development/iac/env".path}" ]; then
            source "${config.sops.secrets."development/iac/env".path}"
          fi
        '';
      };

      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "iac";
          isConfig = false; # Para configuraciones globales de CLI (ej. ~/.terraform.rc, ~/.pulumi)
        }
      ];

      sops.secrets."development/iac/env" = mkIf cfg.useSecrets {};
    };
  };
}
