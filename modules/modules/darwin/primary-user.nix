{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkEnableOption mkIf;
  cfg = config.my.primaryUser;
in {
  flake.darwinModules.primaryUser = {
    options.my.mainUser = {
      enable = mkEnableOption "Define primeary USER for dariwn host";
      username = {
        type = types.str;
      };
    };

    config = mkIf cfg.enable {
      system.primaryUser = cfg.username;
    };
  };
}
