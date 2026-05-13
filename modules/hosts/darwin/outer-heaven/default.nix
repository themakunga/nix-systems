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
      commonModules.nix-settings
      commonModules.state-version

      darwinModules.common

      sops-nix.darwinModules.sops
      commonModules.secrets-management

      nix-homebrew.darwinModules.nix-homebrew
      {
        networking.hostName = "outer-heaven";

        services.openssh.enable = true;

        nix-hoembrew.user = "nicolas";
      }
      home-manager.darwinModules.home-manager
    ];
  };
}
