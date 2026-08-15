# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.ruby
# =========================================================
{
  flake.developmentModules.ruby = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.development.ruby;
  in {
    options.my.development.ruby = {
      enable = mkEnableOption "Ruby development toolkit (Runtime, LSP, Bundler)";

      package = mkOption {
        type = types.package;
        default = pkgs.ruby;
        description = "Versión de Ruby a utilizar";
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
          # Runtime base
          cfg.package

          # Herramientas del ecosistema
          bundler

          # LSPs y Linters
          ruby-lsp # El LSP oficial soportado por Shopify/Shopify
          rubocop # Linter y formatter estándar en Ruby
        ];
        interactiveShellInit = mkIf cfg.useSecrets ''
          if [ -f "${config.sops.secrets."development/ruby/env".path}" ]; then
            source "${config.sops.secrets."development/ruby/env".path}"
          fi
        '';
      };

      # Configuración Pública
      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "ruby";
          isConfig = false;
        }
      ];

      # Configuración Sensible (Tokens de Rubygems privados, etc)
      sops.secrets."development/ruby/env" = mkIf cfg.useSecrets {};
    };
  };
}
