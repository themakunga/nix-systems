# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: performance.nix
# Path: ./modules/modules/rpi/performance.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.rpiModules.performance = {
    swapDevices = [
      {
        device = "/swapfile";
        size = 8 * 1024;
        priority = 10;
      }
    ];

    boot.kernel.sysctl = {
      "wm.swappiness" = 10;
      "wm.dirty_writeback_centisecs" = 6000;
    };
  };
}
