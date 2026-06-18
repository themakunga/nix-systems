{
  self,
  inputs,
  globalConfigurations,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    nixos-hardware
    disko
    sops-nix
    home-manager
    ;
  inherit
    (self)
    commonModules
    rpiModules
    # nixosModules
    profileModules
    homeManagerModules
    ;

  inherit
    (profileModules)
    galadriel
    elron
    gandalf
    ;
in {
  flake.nixosConfigurations.rivendell = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
    };

    modules = [
      commonModules.settings
      nixos-hardware.nixosModules.raspberry-pi-5
      disko.nixosModules.disko
      rpiModules.disko.rivendell
      rpiModules.boot-loader
      rpiModules.systemPackages
      rpiModules.boot
      rpiModules.config
      sops-nix.nixosModules.sops

      elron.system
      galadriel.system

      home-manager.nixosModules.home-manager
      homeManagerModules.common
      {
        home-manager.users = {
          elron = elron.user;
          galadriel = galadriel.user;
          gandalf = gandalf.user;
        };
      }

      {
        nixpkgs.hostPlatform = "aarch64-linux";
        system.stateVersion = globalConfigurations.stateVersion.nixos;
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
