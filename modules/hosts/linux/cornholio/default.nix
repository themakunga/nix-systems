{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    nixos-hardware
    disko
    sops-nix
    ;
  inherit
    (self)
    nixosModules
    commonModules
    diskModules
    ;
in {
  flake = {
    nixosConfigurations.cornholio = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {};
      modules = [
        commonModules.nix-settings
        commonModules.state-version

        disko.nixosModules.disko
        diskModules.cornholio

        sops-nix.nixosModules.sops
        commonModules.secrets-management

        nixosModules.boot-loader
        {
          networking.hostName = "cornholio";

          services.openssh.enable = true;

          zramSwap.enable = true;
        }
      ];
    };
    builderModules.cornholio = nixosModules.bootstrap {
      system = "aarch64-linux";
      hardware = nixos-hardware.nixosModules.raspberry-pi-zero-two;
      hostname = "cornholio";
      authorizedKeys = [];
      extraModules = [];
    };
  };
}
