{
  self,
  inputs,
  globals,
  ...
}:
let
  inherit (inputs)
    nixpkgs
    home-manager
    sops-nix
    ;

  inherit (self)
    commonModules
    nixosModules
    rpiModules
    profileModules
    ;
  inherit (profileModules)
    celebrimbor
    ;
  inherit (globals)
    stateVersion
    ;
in
{
  flake.nixosConfigurations.eregoin = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
    };

    modules = [
      commonModules.settings
      sops-nix.nixosModules.sops

      rpiModules.boot-loader
      rpiModules.systemPackages
      rpiModules.config

      commonModules.userProfiles
      commonModules.authorizedKeys

      celebrimbor.system

      home-manager.nixosModules.home-manager
      commonModules.home-manager
      {
        home-manager.users = {
          celebrimbor = celebrimbor.user;
        };
      }
      nixosModules.wifi
      {
        nixpkgs.hostPlatform = "aarch64-linux";
        system.stateVersion = stateVersion.nixos;

        networking = {
          hostName = "eregoin";
          networkmanager.enable = false;
        };

        services.openssh.enable = true;
      }
    ];
  };
}
