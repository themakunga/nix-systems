{ inputs, ... }:
let
  inherit (inputs)
    nix-darwin
    nix-homebrew
    sops-nix
    secrets
    self
    ;
in
{
  flake.darwinConfigurations = {
    "kanagawa" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit secrets; };
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
    "outer-heaven" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit secrets; };
      modules = [
        self.commonModules.nix-settngs
      ];
    };
  };
}
