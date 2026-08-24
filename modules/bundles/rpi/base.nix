# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: base.nix
# Path: ./modules/bundles/rpi/base.nix
# Description: Bundle specs compartidos para hosts Raspberry Pi.
#              Usar con self.lib.extendBundle en archivos de host.
# =====================
_: {
  flake.bundle.rpi = {
    # -------------------------------------------------------
    # base: módulos mínimos comunes a TODOS los hosts RPi.
    # Extender con extendBundle añadiendo hardware y perfil SD.
    # -------------------------------------------------------
    base = {
      commonModules = [
        "arch.nixos.rpi"
        "authorized-keys"
        "network"
      ];
      rpiModules = ["common"];
    };

    # -------------------------------------------------------
    # bootstrap-rpi5: imagen SD efímera para instalación
    # inicial en Raspberry Pi 5. Uso único, no para installs
    # permanentes.
    # -------------------------------------------------------
    bootstrap-rpi5 = {
      commonModules = [
        "arch.nixos.rpi"
        "authorized-keys"
        "network"
      ];
      nixosModules = ["wifi"];
      rpiModules = [
        "common"
        "hardware-rpi5"
        "sd-image-rpi5"
      ];
    };
  };
}
