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
      # 🚀 Aquí declaramos que es un sistema ARM de 64 bits (aarch64-linux)
      commonModules.arch.nixos.rpi

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
          assignTo = ["root" "nixos"];
        };

        sdImage.compressImage = false;

        systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
      })
    ];
  };
}
