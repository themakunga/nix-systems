{
  self,
  inputs,
  ...
}: let
  inherit (self) commonModules homeManagerModules;
in {
  flake.commonModules.home-manager = {
    imports = [
      commonModules.sops.gpg
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {
        inherit inputs self;
      };

      sharedModules = [
        homeManagerModules.common
      ];
    };
  };
}
