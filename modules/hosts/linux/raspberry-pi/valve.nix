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
    nixosModules
    ;
in {
  flake.nixosConfigurations.valve = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "valve";
    };

    modules = [
      commonModules.arch.nixos.rpi
      commonModules.settings

      nixos-hardware.nixosModules.raspberry-pi-5

      rpiModules.config
      rpiModules.documentationDisable
      rpiModules.boot
      rpiModules.boot-loader
      rpiModules.systemPackages
      nixosModules.wifi

      commonModules.network
      commonModules.authorizedKeys

      ({lib, ...}: {
        networking.hostName = "valve";

        services.openssh.settings.PermitRootLogin = "yes";

        my.authorizedKeys = {
          enable = true;
          assignTo = ["root"];
        };

        systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
      })
    ];
  };
}
