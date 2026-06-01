{
  self,
  inputs,
  ...
}:
let
  inherit (inputs)
    nix-darwin
    nix-homebrew
    home-manager
    ;
  inherit (self)
    darwinModules
    commonModules
    homeManagerModules
    profileModules
    ;
in
{

  flake = {
    profileModules.bigboss = {

    };
    darwinConfigurations.outer-heaven = nix-darwin.lib.darwinSystem {
      specialArgs = { };
      system = "aarch64-darwin";
      modules = [
        commonModules.settings
        darwinModules.common
        commonModules.home-manager-config

        nix-homebrew.darwinModules.nix-homebrew
        {
          networking.hostName = "outer-heaven";
          services.openssh.enable = true;
          nix-homebrew.user = "nicolas";
        }

        profileModules.bigboss.system
        profileModules.bigboss.darwin

        home-manager.darwinModules.home-manager
        {
          home-manager.users.nicolas = {
            imports = [
              profileModules.bigboss.user
            ];
          };
        }
      ];
    };
  };
}
