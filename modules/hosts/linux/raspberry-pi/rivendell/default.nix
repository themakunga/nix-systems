{
  self,
  inputs,
  globals,
  ...
}:
let
  inherit (inputs)
    nixpkgs
    nixos-hardware
    disko
    sops-nix
    home-manager
    ;
  inherit (self)
    commonModules
    rpiModules
    profileModules
    ;

  inherit (profileModules)
    galadriel
    elron
    gandalf
    ;
  inherit (globals)
    stateVersion
    ;
in
{
  flake.nixosConfigurations.rivendell = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
    };

    modules = [
      commonModules.settings

      commonModules.userProfiles
      commonModules.authorizedKeys

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
      gandalf.system

      home-manager.nixosModules.home-manager
      {
        imports = [
          commonModules.home-manager
        ];
        home-manager.users = {
          elron = elron.user;
          galadriel = galadriel.user;

        };
      }

      {
        nixpkgs.hostPlatform = "aarch64-linux";
        system.stateVersion = stateVersion.nixos;
        networking = {
          hostName = "rivendell";
        };

        fileSystems."/".device = nixpkgs.lib.mkForce "/dev/disk/by-partlabel/disk-main-root";

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
