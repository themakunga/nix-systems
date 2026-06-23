{ self, inputs, ... }:
{
  flake.commonModules.home-manager = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {
        inherit inputs self;
      };

      sharedModules = [
        self.homeManagerModules.common
      ];
    };
  };
}
