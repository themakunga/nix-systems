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
  flake.nixosConfigurations.lab42 = nixpkgs.lib.nixosSyste {
    system = "x86_64-linux";
    specialsArgs = { inherit secrets dotfiles; };
    modules = [
      sops-nix.nixosModules.sops
    ];
  };
}
