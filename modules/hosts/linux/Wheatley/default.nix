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
    ;
in {
  flake = {
    nixosConfigurations = {
      wheatley = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {};
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-3
          commonModules.nix-settings
          commonModules.state-version

          disko.nixosModules.disko
          nixosModules.wheatley-disk

          sops-nix.nixosModules.sops
          commonModules.secrets-management

          nixosModules.boot-loader
          {
            networking.hostName = "wheatley";

            services.openssh.enable = true;

            zramSwap.enable = true;
          }
        ];
      };
      wheatley-build = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          nixosModules.rapsberry-pi-config
          nixos-hardware.nixosModules.raspberry-pi-3 # its the same board
        ];
      };
    };
  };
}
