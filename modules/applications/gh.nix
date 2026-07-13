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
        types.submodule ({name, ...}: {
          options = {
            enable = mkEnableOption "Configure multiprofile github cli";
            name = mkOption {
              type = types.str;
              default = name;
              description = "Single word env name";
            };
          };
        })
      );
    };

    config = mkIf (enabledProfiles != {}) {
      environment.systemPackages = [pkgs.gh];

      environment.shellAliases =
        mapAttrs' (
          _n: v:
            lib.nameValuePair "gh_${v.name}" "GH_CONFIG_DIR=~/.config/gh/profile_${v.name} gh"
        )
        enabledProfiles;
    };
  };
}
