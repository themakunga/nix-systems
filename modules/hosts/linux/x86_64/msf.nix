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
    secrets
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
      commonModules.host-secrets
      {
        my.hostSecrets.file = "${secrets.outPath}/hosts/msf.yaml";
      }

      commonModules.userProfiles
      commonModules.authorizedKeys
      commonModules.network

      home-manager.nixosModules.home-manager
      commonModules.home-manager

      userModules.media
      profileModules.mediaserver

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
