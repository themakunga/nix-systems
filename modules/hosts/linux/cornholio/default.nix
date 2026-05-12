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
    nixosConfigurations = {
      cornholio = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {};
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-3
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
    };
  };
}
