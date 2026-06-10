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
    rpiModules
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
      commonModules.settings
      nixos-hardware.nixosModules.raspberry-pi-5
      disko.nixosModules.disko
      rpiModules.disko.rivendell
      sops-nix.nixosModules.sops
      {
        networking = {
          hostName = "rivendell";
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
