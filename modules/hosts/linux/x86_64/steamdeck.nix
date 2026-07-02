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
  flake.nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "steamdeck";
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

      userModules.deck
      profileModules.steamdeck
      nixosModules.base-machine
      {
        my = {
          hostSecrets.file = "${secrets.outPath}/hosts/steamdeck.yaml";
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
