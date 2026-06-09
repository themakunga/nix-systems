{ self, inputs, ... }:
let
  inherit (inputs)
    nixpkgs
    nixos-hardware
    disko
    sops-nix
    ;
  inherit (self)
    commonModules
    nixosModules
    profileModules
    ;

  inherit (profileModules)
    galadriel
    elron
    ;
in
{
  flake.nixosConfigurations.rivendell = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = {
      inherit inputs;
    };

    modules = [
      { nixpkgs.hostPlaform = "aarch64-linux"; }
      commonModules.settings
      nixos-hardware.nixosModules.raspberry-pi-5
      disko.nixosModules.disko
      nixosModules.disko-configurations.rivendell
      sops-nix.nixosModules.sops
      {
        networking = {
          hostnname = "rivendell";
        };

        boot = {
          loader = {
            grub.enable = false;
            generic-extlinux-compatible.enable = true;
          };
        };

        services.openssh = {

        };

      }

    ];
  };

}
