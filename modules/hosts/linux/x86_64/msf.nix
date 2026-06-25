{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    sops-nix
    home-manager
    ;
  inherit
    (self)
    nixosModules
    commonModules
    userModules
    profileModules
    ;
in {
  flake.nixosConfigurations.msf = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "mfs";
    };

    modules = [
      commonModules.arch.nixos.x64
      commonModules.settings
      sops-nix.nixosModules.sops

      commonModules.userProfiles
      commonModules.authorizedKeys
      commonModules.network

      home-manager.nixosModules.home-manager
      commonModules.home-manager

      userModules.server
      profileModules.manager
      nixosModules.base-machine
      {
        my.base-machine = {
          enable = true;
          bootMode = "uefi";
          rootDevice = "/dev/nvme0u1p2";
        };
      }
    ];
  };
}
