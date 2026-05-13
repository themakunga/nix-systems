{
  inputs,
  self,
  ...
}: let
  inherit
    (inputs)
    nix-darwin
    nix-homebrew
    home-manager
    sops-nix
    ;
  inherit
    (self)
    commonModules
    darwinModules
    ;
in {
  flake.darwinConfigurations = {
    "kanagawa" = nix-darwin.lib.darwinSystem {
      specialArgs = {};
      system = "aarch64-darwin";
      modules = [
        commonModules.nix-settings
        commonModules.state-version

        darwinModules.common

        sops-nix.darwinModules.sops
        commonModules.secrets-management

        nix-homebrew.darwinModules.nix-homebrew
        {
          networking.hostName = "kanagawa";

          services.openssh.enable = true;

          nix-homebrew.user = "nicolas";
        }
        home-manager.darwinModules.home-manager
      ];
    };
  };
}
