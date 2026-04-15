{ inputs }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  mkNixosSystem =
    {
      system,
      hostname,
      username,
      extraModules ? [ ],
    }:
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          hostname
          system
          username
          ;
      };
      modules = [
        ../hosts/linux/${hostname}/default.nix
        ../users/${username}/home.nix
        ../shared/overlays/default.nix
        inputs.home-manager.nixosModule.home-manager
      ]
      ++ extraModules;
    };

  mkDarwinSystem =
    {
      system,
      hostname,
      username,
      extraModules ? [ ],
    }:
    inputs.darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          hostname
          system
          username
          ;
      };
      modules = [
        ../hosts/darwin/${hostname}/default.nix
        ../users/${username}/home.nix
        ../shared/overlays/default.nix
        inputs.home-manager.darwinModules.home-manager
      ]
      ++ extraModules;
    };

  mkSdImage = nixosConfig: nixosConfig.config.system.build.sdImage;
}
