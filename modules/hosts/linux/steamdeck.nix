# SteamDeck bazzite

{ inputs, ... }:
let
  inherit (inputs) nixpkgs sops-nix secrets;
in
{
  flake = {
    nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit secrets; };
      modules = [
        sops-nix.nixosModules.sops
      ];
    };
  };
}
