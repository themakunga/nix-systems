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
    sops-nix
    ;
  inherit
    (self)
    darwinModules
    commonModules
    ;
in {
  flake.darwinConfigurations.outer-heaven = nix-darwin.lib.darwinSystem {
    specialArgs = {};
    system = "aarch64-darwin";
    modules = [
      commonModules.settings
      darwinModules.common

      sops-nix.darwinModules.sops

      nix-homebrew.darwinModules.nix-homebrew
      {
        networking.hostName = "outer-heaven";

        services.openssh.enable = true;

        nix-homebrew.user = "nicolas";
      }
      home-manager.darwinModules.home-manager
    ];
  };
}
