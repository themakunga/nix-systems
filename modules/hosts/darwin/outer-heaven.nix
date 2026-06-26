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
  flake.darwinConfigurations.outer-heaven = nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "outher-heaven";
    };

    modules = [
      commonModules.arch.darwin.silicon
      commonModules.settings
      sops-nix.darwinModules.sops
      commonModules.userProfiles
      commonModules.network

      darwinModules.common

      nix-homebrew.darwinModules.nix-homebrew
      darwinModules.homebrew

      home-manager.darwinModules.home-manager
      commonModules.home-manager

      userModules.nicolas-work
      profileModules.nicolas-work
      profileModules.thoughtworks
      profileModules.grainger
    ];
  };
}
