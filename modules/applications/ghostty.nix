# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.ghostty = mkAppModule "ghostty" "Enable Ghostty terminal emulator" {
    meta = {
      pkgs,
      lib,
      ...
    }: {
      level = "system";
      packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.ghostty];
      casks = lib.optionals pkgs.stdenv.hostPlatform.isDarwin ["ghostty"];
    };
    sysConfig = {
      my.dotfiles.packages = [
        {
          name = "ghostty";
          isConfig = true;
        }
      ];
    };
  };
}
