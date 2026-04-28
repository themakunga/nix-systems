# Server Linux

{ inputs, ... }:
let
  inherit (inputs) nixpkgs sops-nix secrets;
in
{
  flake = {
    nixosConfigurations.motherbase = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit secrets; };
      modules = [
        sops-nix.nixosModules.sops
      ];
    };
  };
}
