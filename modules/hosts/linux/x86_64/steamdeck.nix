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
    ;
  inherit
    (self)
    nixosModules
    commonModules
    userModules
    profileModules
    ;
in {
  flake.nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "steamdeck";
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

      userModules.deck
      profileModules.steamdeck
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
