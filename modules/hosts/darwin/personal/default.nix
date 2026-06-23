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
    profileModules
    ;
in
{
  flake.darwinConfigurations.gondor = nix-darwin.lib.darwinSystem {
    specialArgs = { inherit self inputs; };
    system = "aarch64-darwin";

    modules = [
      commonModules.settings
      darwinModules.common
      commonModules.home-manager-config

      commonModules.userProfiles
      commonModules.authorizedKeys

      nix-homebrew.darwinModules.nix-homebrew
      {
        nerworking.hpstName = "gondor";
        services.opensh.enable = true;
        nix-homebrew.user = "nicolas";
      }

      profileModules.aragon.system
      profileModules.aragon.darwin

      home-manager.darwinModules.home-manager
      {
        home-manager = {
          extraSpecialArgs = { inherit self inputs; };
          uses.nicolas = {
            imports = [
              profileModules.aragon.user
              profileModules.boromir.user
              profileModules.faramir.user
            ];
          };
        };
      }
    ];
  };
}
