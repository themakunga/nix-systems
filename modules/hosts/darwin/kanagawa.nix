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
    commonModules
    userModules
    darwinModules
    profileModules
    ;
in {
  flake.darwinConfigurations.kanagawa = nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "kanagawa";
    };

    modules = [
      commonModules.arch.darwin.silicon
      commonModules.settings
      sops-nix.darwinModules.sops
      commonModules.userProfiles
      commonModules.network

      darwinModules.common

      nix-homebrew.darwinModules.nix-homebrew
      darwinModules.homebrew-config

      home-manager.darwinModules.home-manager
      commonModules.home-manager

      userModules.nicolas-personal
      profileModules.nicolas-personal
      profileModules.nicolas-42devs
      profileModules.nicolas-bbook
    ];
  };
}
