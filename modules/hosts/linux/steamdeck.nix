{ inputs, ... }:
let
  inherit (inputs)
    nixpkgs
    sops-nix
    secrets
    dotfiles
    ;
in
{
  flake.nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit secrets dotfiles; };
    modules = [
      sops-nix.nixosModules.sops
    ];
  };
}
