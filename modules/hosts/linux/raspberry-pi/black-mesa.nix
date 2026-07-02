{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    home-manager
    sops-nix
    nixos-hardware
    disko
    secrets
    ;
  inherit
    (self)
    nixosModules
    rpiModules
    commonModules
    userModules
    profileModules
    ;
in {
  flake.nixosConfigurations.black-mesa = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "black-mesa";
    };

    modules = [
      commonModules.arch.nixos.rpi
      commonModules.settings
      sops-nix.nixosModules.sops
      commonModules.host-secrets
      {
        my.hostSecrets = "${secrets}/hosts/black-mesa.yaml";
      }

      commonModules.userProfiles
      commonModules.authorizedKeys
      commonModules.network

      nixos-hardware.nixosModules.raspberry-pi-3
      disko.nixosModules.disko
      rpiModules.disko.black-mesa
      rpiModules.boot-loader
      rpiModules.systemPackages
      rpiModules.config

      home-manager.nixosModules.home-manager
      commonModules.home-manager

      userModules.nicolas-pihole
      profileModules.pihole

      nixosModules.base-machine
      {
        my.base-machine = {
          enable = true;
          bootMode = "rpi";
        };

        fileSystems."/".device = nixpkgs.lib.mkForce "/dev/disk/by-partlabel/disk-main-root";
      }
    ];
  };
}
