{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nix-darwin
    nix-homebrew
    home-manager
    ;
  inherit
    (self)
    darwinModules
    commonModules
    profileModules
    ;
in {
  flake.darwinConfigurations.rohan = nix-darwin.lib.darwinSystem {
    specialArgs = {inherit self inputs;};
    system = "aarch64-darwin";

    modules = [
      commonModules.settings
      darwinModules.common
      commonModules.home-manager-config

      nix-homebrew.darwinModules.nix-homebrew
      {
        networking.hostName = "rohan";
        services.openssh.enable = true;
        nix-homebrew.user = "nicolas";
      }

      profileModules.theoden.system
      profileModules.theoden.darwin

      home-manager.darwinModules.home-manager
      {
        home-manager.extraSpecialArgs = {inherit self inputs;};

        home-manager.users.nicolas = {
          imports = [
            profileModules.theoden.user
            profileModules.eomer.user
            profileModules.eowyn.user
          ];
        };
      }
    ];
  };
}
