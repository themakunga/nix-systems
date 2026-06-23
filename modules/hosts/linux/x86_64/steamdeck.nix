{ self, inputs, ... }:
let
  inherit (inputs)
    nixpkgs
    nix-homebrew
    home-manager
    ;
  inherit (self)
    nixosModules
    commonModules
    userModules
    profileModules
    ;
in
{
  flake.nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
    scpecialArgs = {
      inherit self inputs;
    };

    system = "x86_64-linux";

    modules = [ ];
  };
}
