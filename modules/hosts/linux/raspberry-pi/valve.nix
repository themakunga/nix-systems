{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    nixos-hardware
    ;
  inherit
    (self)
    rpiModules
    commonModules
    ;
in {
  flake.nixosConfigurations.valve = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "valve";
    };

    modules = [
      commonModules.arch.nixos.rpi
      commonModules.settings # <--- Corrige el warning de stateVersion

      nixos-hardware.nixosModules.raspberry-pi-5

      rpiModules.config
      rpiModules.documentationDisable

      commonModules.network
      commonModules.authorizedKeys

      ({lib, ...}: {
        networking.hostName = "valve";

        services.openssh.settings.PermitRootLogin = "yes";

        my.authorizedKeys = {
          enable = true;
          assignTo = ["root"]; # <--- Eliminamos "nixos" para evitar el error de aserción
        };

        sdImage.compressImage = false;

        systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
      })
    ];
  };
}
