# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.beeptui = mkAppModule "beeptui" "TUI for Beeper" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [
        (pkgs.callPackage "${self}/packages/beeptui/package.nix" {})
      ];
      casks = ["beeper"];
    };
  };
}
