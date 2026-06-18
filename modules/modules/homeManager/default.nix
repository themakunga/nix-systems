{globalConfigurations, ...}: let
  inherit (globalConfigurations) stateVersion;
in {
  flake.homeManagerModules.common = {
    home.stateVersion = stateVersion.home-manager;
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    programs = {
      home-manager.enable = true;
      git = {
        enable = true;
        extraConfig.init.defaultBranch = "main";
      };
    };
  };
}
