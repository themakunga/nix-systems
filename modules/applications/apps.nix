{
  flake.applicationModules.apps = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit
      (lib)
      mkOption
      types
      mkEnableOption
      mkIf
      mkMerge
      filterAttrs
      mapAttrsToList
      flatten
      unique
      foldl'
      ;
    inherit
      (types)
      str
      attrsOf
      submodule
      enum
      listOf
      package
      ;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    cfg = config.my.apps;
  in {
    options.my.apps = mkOption {
      default = {};
      description = "Generic motor apps";
      type = attrsOf (submodule {
        options = {
          enable = mkEnableOption "Activate group";
          level = mkOption {
            type = enum ["system" "user"];
            default = "system";
          };
          targetUser = mkOption {
            type = str;
            default = "nicolas";
          };
          packages = mkOption {
            type = listOf package;
            default = [];
          };
          casks = mkOption {
            type = listOf str;
            default = [];
          };
        };
      });
    };

    config = let
      activeApps = filterAttrs (_: g: g.enable) cfg;
      systemApps = filterAttrs (_: g: g.level == "system") activeApps;
      userApps = filterAttrs (_: g: g.level == "user") activeApps;

      sysPackages = flatten (mapAttrsToList (_: g: g.packages) systemApps);
      sysCasks = flatten (mapAttrsToList (_: g: g.casks) systemApps);

      uniqueUsers = unique (mapAttrsToList (_: g: g.targetUser) userApps);
      userPackagesConfig =
        foldl' (
          acc: user: let
            userPkgs = flatten (mapAttrsToList (_: g: g.packages) (filterAttrs (_: g:
              g.targetUser == user)
            userApps));
          in
            acc
            // {
              ${user} = {
                home.packages = userPkgs;
              };
            }
        ) {}
        uniqueUsers;

      userCasks = flatten (mapAttrsToList (_: g: g.casks) userApps);
    in
      mkMerge [
        (mkIf (sysPackages != []) {
          environment.systemPackages = sysPackages;
        })

        (mkIf (isDarwin && (sysCasks != [] || userCasks != [])) {
          homebrew.casks = sysCasks ++ userCasks;
        })

        (mkIf (userPackagesConfig != {}) {
          home-manager.users = userPackagesConfig;
        })
      ];
  };
}
