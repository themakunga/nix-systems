{
  flake.commonModules.home-manager-config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
