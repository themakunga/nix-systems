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
  flake.darwinConfigurations.kanagawa = nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "kanagawa";
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
          hostSecrets.file = "${secrets.outPath}/hosts/kanagawa.yaml";
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

      userModules.nicolas-personal
      profileModules.nicolas-personal
      profileModules.nicolas-42devs
      profileModules.nicolas-bbook
    ];
  };
}
