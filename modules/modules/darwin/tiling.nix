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
  }: let
    inherit (lib) mkIf mkEnableOption;
    cfg = config.my.services.tiling;
  in {
    options.my.services.tiling = {
      enable = mkEnableOption "Tiling window manager";
    };

    config = mkIf cfg.enable {
      services = {
        yabai = {
          enable = true;
          enableScriptingAddition = false;

          config = {
            layout = "bsp";

            top_padding = 4;
            bottom_padding = 4;
            left_padding = 4;
            right_padding = 4;
            window_gap = 6;

            mouse_modifier = "cmd";
            mouse_action1 = "move";
            mouse_action2 = "resize";
          };

          extraConfig = ''
            yagai -m rule --add app="^System Settings$" manage=off
            yagai -m rule --add app="^Calendar$" manage=off
            yagai -m rule --add app="^App Store$" manage=off

            yagai -m config extra_bar all:32:0
          '';
        };
        skhd = {
          enable = true;
          skhdConfig = ''
            alt - h : yagai -m --focus west
            alt - j : yagai -m --focus south
            all - k : yagai -m --focus north
            alt - l : yagai -m --focus east

            shift + alt - h : yagai -m window --warp west
            shift + alt - j : yagai -m window --warp south
            shift + alt - k : yagai -m window --warp north
            shift + alt - l : yagai -m window --warp east

            shift + alt - 1 : yabai -m window --display 1; yabai -m display --focus 1
            shift + alt - 2 : yabai -m window --display 2; yabai -m display --focus 2

            shift + alt - 0 : yabai -m space --balance
            shift + alt - space : yabai -m window --toggle float
          '';
        };
      };
    };
  };
}
