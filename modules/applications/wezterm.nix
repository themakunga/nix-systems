# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.wezterm = mkAppModule "wezterm" "Enable WezTerm terminal emulator" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = with pkgs; [
        wezterm
      ];
    };
    sysConfig = {
      my.dotfiles.packages = [
        {
          # wezterm/ → stow → ~/.wezterm.lua
          # Config: color_scheme = "Tokyo Night Storm", Hack Nerd Font 14pt
          name = "wezterm";
        }
      ];
    };
  };
}
