# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Tiling window manager module for macOS using AeroSpace.
# AeroSpace manages its own startup via start-at-login in aerospace.toml.
{
  flake.darwinModules.tiling = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.my.services.tiling.enable = lib.mkEnableOption "Tiling window manager";
    config = lib.mkIf config.my.services.tiling.enable {
      my.dotfiles = {
        enable = true;
        packages = [
          {
            name = "aerospace";
            isConfig = true;
          }
        ];
      };
      environment.systemPackages = [pkgs.aerospace];
    };
  };
}
