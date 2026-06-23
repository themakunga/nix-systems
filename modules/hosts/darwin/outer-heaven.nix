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
  flake.darwinConfigurations.outer-heaven = nix-darwin.lib.darwinSystem {
    scpecialArgs = {
      inherit self inputs;
    };

    system = "aarch64-darwin";

    modules = [ ];
  };
}
