# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.nchat = mkAppModule "nchat" "Enable nchat terminal messaging client" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.nchat];
    };
    sysConfig = {
      my.dotfiles.packages = [
        {
          name = "nchat";
          isConfig = true; # Esto le indica a GNU Stow que lo enlace en ~/.config/nchat
        }
      ];
    };
  };
}
