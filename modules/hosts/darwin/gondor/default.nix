{
  inputs,
  self,
  ...
}:
let
  inherit (inputs)
    nix-darwin
    nix-homebrew
    home-manager
    sops-nix
    ;
  inherit (self)
    commonModules
    darwinModules
    ;
in
{
  flake.darwinConfigurations.big-shell = nix-darwin.lib.darwinSystem {
    specialArgs = { };
    system = "aarch64-darwin";
    modules = [
      commonModules.settings

      darwinModules.common

      sops-nix.darwinModules.sops

      nix-homebrew.darwinModules.nix-homebrew
      {
        networking.hostName = "kanagawa";

        services.openssh.enable = true;

        nix-homebrew.user = "nicolas";
      }
      home-manager.darwinModules.home-manager
    ];
  };
}
