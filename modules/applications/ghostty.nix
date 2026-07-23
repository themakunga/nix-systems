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
  flake.applicationModules.ghostty = mkAppModule "ghostty" "Enable Ghostty terminal emulator" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [
        pkgs.ghostty
      ];
    };
  };
}
