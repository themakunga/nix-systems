{ inputs, ... }:
let
  inherit (inputs)
    nix-darwin
    nix-homebrew
    sops-nix
    secrets
    dotfiles
    ;
in
{
  flake.darwinConfigurations.outer-heaven = nix-darwin.lib.darwinSystem {
    specialArgs = { inherit secrets dotfiles; };
    modules = [
      sops-nix.darwinModules.sops
      nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          autoMigrate = true;
          user = "nicolas";
        };
      }
    ];
  };
}
