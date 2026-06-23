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
  flake.nixosConfigurations.aperture-science = nixpkgs.lib.nixosSystem {
    scpecialArgs = {
      inherit self inputs;
    };

    system = "aarch64-linux";

    modules = [ ];
  };
}
