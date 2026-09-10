# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# rpi.base          - minimal modules shared by all RPi hosts
# rpi.bootstrap-rpi5 - ephemeral SD image for first-time Pi 5 provisioning
_: {
  flake.bundle.rpi = rec {
    base = {
      commonModules = ["arch.nixos.rpi" "authorized-keys" "network"];
      rpiModules = ["common"];
    };

    bootstrap-rpi5 =
      base
      // {
        nixosModules = ["wifi"];
        rpiModules = base.rpiModules ++ ["hardware-rpi5" "sd-image-rpi5"];
      };
  };
}
