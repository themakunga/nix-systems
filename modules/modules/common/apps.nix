# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{
  flake.commonModules.apps = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types mkEnableOption mkIf mkMerge filterAttrs mapAttrsToList flatten foldl';
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    cfg = config.my.apps;
  in {
    options.my.apps = mkOption {
      default = {};
      description = "Smart Application Routing Engine";
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "Enable this application group";
          level = mkOption {
            type = types.enum ["system" "user"];
            default = "system";
          };
          targetUser = mkOption {
            type = types.str;
            default = "nicolas";
          };
          packages = mkOption {
            type = types.listOf types.package;
            default = [];
            description = "Native Nixpkgs derivations";
          };
          casks = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Homebrew Casks (macOS only)";
          };
          masApps = mkOption {
            type = types.attrsOf types.ints.unsigned;
            default = {};
            description = "Mac App Store IDs (macOS only)";
          };
        };
      });
    };

    config = let
      activeApps = filterAttrs (_: g: g.enable) cfg;
      sysApps = filterAttrs (_: g: g.level == "system") activeApps;
      userApps = filterAttrs (_: g: g.level == "user") activeApps;

      sysPackages = flatten (mapAttrsToList (_: g: g.packages) sysApps);
      sysCasks = flatten (mapAttrsToList (_: g: g.casks) sysApps);
      sysMasApps = foldl' (acc: g: acc // g.masApps) {} (builtins.attrValues sysApps);

      uniqueUsers = lib.unique (mapAttrsToList (_: g: g.targetUser) userApps);
      userPackagesConfig = foldl' (acc: user: let
        userPkgs = flatten (mapAttrsToList (_: g: g.packages) (filterAttrs (_: g: g.targetUser == user) userApps));
      in
        acc // {${user} = {home.packages = userPkgs;};}) {}
      uniqueUsers;

      userCasks = flatten (mapAttrsToList (_: g: g.casks) userApps);
      userMasApps = foldl' (acc: g: acc // g.masApps) {} (builtins.attrValues userApps);
    in
      mkMerge [
        (mkIf (sysPackages != []) {
          environment.systemPackages = sysPackages;
        })

        (mkIf isDarwin {
          homebrew.casks = sysCasks ++ userCasks;
          homebrew.masApps = sysMasApps // userMasApps;
        })

        (mkIf (userPackagesConfig != {}) {
          home-manager.users = userPackagesConfig;
        })
      ];
  };
}
