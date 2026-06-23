{ self, inputs, ... }:
let
  inherit (inputs)
    nix-darwin
    nix-homebrew
    home-manager
    ;
  inherit (self)
    darwinModules
    commonModules
    userModules
    profileModules
    ;
in
{
  flake.darwinConfigurations.kanagawa = nix-darwin.lib.darwinSystem {
    scpecialArgs = {
      inherit self inputs;
    };

    system = "aarch64-darwin";

    modules = [
      commonModules.settings
      darwinModules.common
      commonModules.home-manager-config

      commonModules.userProfiles
      commonModules.authorizedKeys
    ];
  };
}
