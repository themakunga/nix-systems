# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.qmk = mkAppModule "qmk" "Enable QMK firmware toolchain" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [
        pkgs.qmk
        pkgs.avrdude
        pkgs.dfu-util
        pkgs.gcc-arm-embedded
        pkgs.pkgsCross.avr.buildPackages.gcc
      ];
    };
  };
}
