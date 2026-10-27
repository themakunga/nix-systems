# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo: developmentModules.lua
# =========================================================
{
  flake.developmentModules.lua = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.development.lua;
  in {
    options.my.development.lua = {
      enable = mkEnableOption "Lua 5.4 runtime and tooling";

      package = mkOption {
        type = types.package;
        default = pkgs.lua5_4;
        description = "Lua package to use (e.g. pkgs.lua5_4, pkgs.luajit)";
      };

      enableLuarocks = mkOption {
        type = types.bool;
        default = true;
        description = "Install LuaRocks package manager";
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages =
        [cfg.package]
        ++ lib.optional cfg.enableLuarocks pkgs.luarocks;
    };
  };
}
