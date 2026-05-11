{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    disko
    sops-nix
    nixos-hardware
    ;
  inherit
    (self)
    nixosModules
    builderModules
    commonModules
    diskModules
    ;
in {
  flake = {
    nixosConfigurations = {
      glados = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {};
        modules = [
          commonModules.nix-settings
          commonModules.state-version

          disko.nixosModules.disko
          diskModules.glaDOS
          commonModules.secrets-management

          sops-nix.nixosModules.sops
          nixosModules.boot-loader
          {
            networking.hostName = "glaDOS";

            services.openssh.enable = true;

            zramSwap.enable = true;
          }
        ];
      };
      glados-builder = builderModules.bootstrap {
        system = "aarch64-linux";
        hardware = nixos-hardware.nixosModules.raspberry-pi-5;
        hostname = "glaDOS";
        authorizedKeys = [];
        extraModules = [];
      };
    };
  };
}
