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
    commonModules
    ;
in {
  flake = {
    nixosConfigurations = {
      glados = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {};
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-5
          commonModules.nix-settings
          commonModules.state-version

          disko.nixosModules.disko
          nixosModules.glaDOS
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
    };
  };
}
