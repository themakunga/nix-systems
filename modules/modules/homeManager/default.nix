{ globals, ... }:
let
  inherit (globals) stateVersion;
in
{
  flake.homeManagerModules.common = {
    home.stateVersion = stateVersion.home-manager;

    programs = {
      home-manager.enable = true;
      git = {
        enable = true;
        extraConfig.init.defaultBranch = "main";
      };
    };
  };
}
