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
    secrets
    ;
  inherit
    (self)
    commonModules
    userModules
    darwinModules
    profileModules
    applicationModules
    ;
in {
  flake.darwinConfigurations.outer-heaven = nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "outer-heaven";
    };

    modules = [
      commonModules.arch.darwin.silicon
      commonModules.settings
      sops-nix.darwinModules.sops
      commonModules.host-secrets
      applicationModules.tailscale
      darwinModules.primaryUser
      {
        my = {
          hostSecrets.file = "${secrets.outPath}/hosts/outer-heaven.yaml";
          tailscale = {
            enable = true;
            gui.enable = true;
          };
          primaryUser = {
            enable = true;
            username = "nicolas";
          };
        };
      }
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
