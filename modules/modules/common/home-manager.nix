{
  flake.commonModules.homeManager = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
