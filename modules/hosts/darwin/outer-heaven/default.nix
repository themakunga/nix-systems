{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nix-darwin
    nix-homebrew
    home-manager
    ;
  inherit
    (self)
    darwinModules
    commonModules
    homeManagerModules
    ;
in {
  flake.darwinConfigurations.outer-heaven = nix-darwin.lib.darwinSystem {
    specialArgs = {};
    system = "aarch64-darwin";
    modules = [
      commonModules.settings
      darwinModules.common

      nix-homebrew.darwinModules.nix-homebrew
      {
        networking.hostName = "outer-heaven";

        services.openssh.enable = true;

        nix-homebrew.user = "nicolas";
      }
      home-manager.darwinModules.home-manager

      homeManagerModules.thougthworks
      homeManagerModules.grainger
    ];
  };
}
