# Server Linux
{ inputs, ... }:
let
  inherit (inputs) nixpkgs sops-nix secrets;
in
{
  flake = {
    nixosConfigurations.mediacenter = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit secrets; };
      modules = [
        sops-nix.nixosModules.sops
      ];
    };
  };
}
