{ inputs, ... }:
let
  inherit (inputs)
    self
    nix-darwin
    nix-homebrew
    home-manager
    sops-nix
    secrets
    dotfiles
    ;
in
{
  flake.darwinModules = {
    "kanagawa" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit secrets dotfiles; };
      system = "aarch64-darwin";
      modules = [
        sops-nix.darwinModules.sops
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew.user = "nicolas";
        }
        home-manager.darwinModules.home-manager
        self.userModules.personal
      ];
    };
  };
}
