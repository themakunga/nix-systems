{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    home-manager
    # disko
    sops-nix
    # nix-hardware
    secrets
    ;
  inherit
    (self)
    nixosModules
    commonModules
    userModules
    profileModules
    applicationModules
    ;
in {
  flake.nixosConfigurations.motherbase = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "motherbase";
    };

    modules = [
      commonModules.arch.nixos.x64
      commonModules.settings
      sops-nix.nixosModules.sops
      commonModules.host-secrets

      commonModules.userProfiles
      commonModules.authorizedKeys
      commonModules.network

      home-manager.nixosModules.home-manager
      commonModules.home-manager

      userModules.nicolas-server
      profileModules.nicolas-server
      applicationModules.tailscale

      nixosModules.base-machine
      {
        my = {
          hostSecrets.file = "${secrets.outPath}/hosts/motherbase.yaml";
          tailscale = {
            enable = true;
            gui.enable = true;
          };
          base-machine = {
            enable = true;
            bootMode = "uefi";
            rootDevice = "/dev/nvme0u1p2";
          };
        };
      }
    ];
  };
}
