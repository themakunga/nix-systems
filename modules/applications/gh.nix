{
  flake.applicationModules.gh = {
    lib,
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkOption types filterAttrs mapAttrs';
    cfg = config.my.gh;

    enabledProfiles = filterAttrs (_n: v: v.enable) cfg;
  in {
    options.my.gh = mkOption {
      default = {};
      description = "Smart multiprofile gh environment";
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkEnableOption "Configure multiprofile github cli";
          };
        }
      );
    };

    config = mkIf (enabledProfiles != {}) {
      environment.systemPackages = [pkgs.gh];

      environment.shellAliases =
        mapAttrs' (
          name: _value:
            lib.nameValuePair "gh_${name}" "GH_CONFIG_DIR=~/.config/gh/profile_${name} gh"
        )
        enabledProfiles;
    };
  };
}
