# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.nodejs
# =========================================================
{
  flake.developmentModules.nodejs = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf optional optionals;
    cfg = config.my.development.nodejs;
  in {
    options.my.development.nodejs = {
      enable = mkEnableOption "JavaScript/TypeScript development toolkit (Node, Bun, Deno, LSPs)";

      package = mkOption {
        type = types.package;
        default = pkgs.nodejs_22;
        description = "Versión de NodeJS a utilizar por defecto (ej. pkgs.nodejs_20, pkgs.nodejs_22)";
      };

      packageManager = mkOption {
        type = types.enum ["npm" "yarn" "pnpm"];
        default = "pnpm";
        description = "Gestor de paquetes preferido para NodeJS";
      };

      enableBun = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar Bun (Runtime, bundler y test runner ultrarrápido)";
      };

      enableDeno = mkOption {
        type = types.bool;
        default = true;
        description = "Habilitar Deno (Runtime seguro para JS/TS con linter y formatter integrados)";
      };

      enableGlobals = mkOption {
        type = types.bool;
        default = true;
        description = "Instalar dependencias globales (TypeScript, ts-node, Jest, etc.) a nivel de sistema";
      };

      useDotfiles = mkOption {
        type = types.bool;
        default = true;
        description = "Mapear configuraciones (ej. .npmrc público, .prettierrc) desde public-dotfiles";
      };

      useSecrets = mkOption {
        type = types.bool;
        default = false;
        description = "Cargar tokens sensibles (ej. NPM_TOKEN para registros privados) desde SOPS";
      };
    };

    config = mkIf cfg.enable {
      environment = {
        systemPackages = with pkgs;
          [
            # Runtime base y Gestor de NodeJS
            cfg.package
            (
              if cfg.packageManager == "yarn"
              then yarn
              else if cfg.packageManager == "pnpm"
              then pnpm
              else null
            )
          ]
          ++ optional cfg.enableBun bun
          ++ optional cfg.enableDeno deno
          # 🛠️ Paquetes Globales del Ecosistema
          ++ optionals cfg.enableGlobals [
            typescript
          ]
          ++ [
            typescript-language-server
            vscode-langservers-extracted # HTML, CSS, JSON, ESLint

            prettier
            eslint

            npm-check-updates
          ];
        interactiveShellInit = mkIf cfg.useSecrets ''
          if [ -f "${config.sops.secrets."development/nodejs/env".path}" ]; then
            source "${config.sops.secrets."development/nodejs/env".path}"
          fi
        '';
      };

      my.dotfiles.packages = mkIf cfg.useDotfiles [
        {
          name = "nodejs";
          isConfig = false; # Stow directo al $HOME para .npmrc o .nvmrc globales
        }
      ];

      sops.secrets."development/nodejs/env" = mkIf cfg.useSecrets {};
    };
  };
}
