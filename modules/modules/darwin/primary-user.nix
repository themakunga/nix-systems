{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption mkIf;
  cfg = config.my.primaryUser;
in {
  flake.darwinModules.primaryUser = {
    options.my.primaryUser = {
      enable = mkEnableOption "Define primeary USER for dariwn host";
      username = mkOption {
        type = types.str;
        description = "main username to asign";
      };
    };

    config = mkIf cfg.enable {
      system.primaryUser = cfg.username;
    };
  };
}
