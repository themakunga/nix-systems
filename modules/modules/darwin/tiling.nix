# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Tiling window manager module for macOS using yabai (BSP layout) and skhd.
{
  flake.darwinModules.tiling = {
    config,
    lib,
    ...
  }: {
    options.my.services.tiling.enable = lib.mkEnableOption "Tiling window manager";
    config = lib.mkIf config.my.services.tiling.enable {
      my.dotfiles = {
        enable = true;
        packages = [
          {
            name = "yabai";
            isConfig = true;
          }
          {
            name = "skhd";
            isConfig = true;
          }
        ];
      };
      services = {
        yabai = {
          enable = true;
          enableScriptingAddition = false;
          extraConfig = ''
            . "$HOME/.config/yabai/yabairc"
          '';
        };
        skhd.enable = true;
      };
    };
  };
}
