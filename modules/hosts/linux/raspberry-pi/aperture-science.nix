{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    home-manager
    disko
    sops-nix
    nixos-hardware
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
  flake.nixosConfigurations.aperture-science = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "aperture-science";
    };

    modules = [
      commonModules.arch.nixos.rpi
      commonModules.settings
      sops-nix.nixosModules.sops

      commonModules.userProfiles
      commonModules.authorizedKeys
      commonModules.network

      nixos-hardware.nixosModules.raspberry-pi-5
      disko.nixosModules.disko
      rpiModules.disko.aperture-science
      rpiModules.boot-loader
      rpiModules.systemPackages
      rpiModules.config

      home-manager.nixosModules.home-manager
      commonModules.home-manager

      userModules.nicolas-admin
      userModules.glados
      profileModules.nicolas-admin
      profileModules.glados

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
