{ inputs, self, ... }:
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
  flake.darwinConfigurations = {
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
        self.usersModules.personal
      ];
    };
  };
}
