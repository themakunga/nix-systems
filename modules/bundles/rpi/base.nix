# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# Raspberry Pi bundle specs. Extend base with extendBundle in host files.
#   rpi.base          - minimal modules shared by all RPi hosts
#   rpi.bootstrap-rpi5 - ephemeral SD image for first-time Pi 5 provisioning
_: {
  flake.bundle.rpi = {
    base = {
      commonModules = [
        "arch.nixos.rpi"
        "authorized-keys"
        "network"
      ];
      rpiModules = ["common"];
    };

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
