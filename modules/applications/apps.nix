# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: apps.nix
# Path: ./modules/applications/apps.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
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
      filter
      splitString
      getAttrFromPath
      ;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    cfg = config.my.apps;

    macCasks = [
      "1password"
      "1password-cli"
      "arc"
      "arduino-ide"
      "bartender"
      "dbeaver-community"
      "discord"
      "figma"
      "firefox"
      "google-chrome"
      "iterm2"
      "logitech-g-hub"
      "mattermost"
      "microsoft-teams"
      "mural"
      "obsidian"
      "qmk-toolbox"
      "rancher"
      "signal"
      "okta-verify"
      "slack"
      "spotify"
      "steam"
      "topnotch"
      "typora@dev"
      "via"
      "visual-studio-code"
      "zoom"
    ];

    macMasApps = {
      "Amphetamine" = 937984704;
      "Apple Configurator" = 1037126344;
      "Be Focused Pro" = 961632517;
      "Magnet" = 441258766;
      "Parcel" = 375589283;
      "Termius" = 1176074088;
      "Whatsapp Messenger" = 310633997;
      "Xcode" = 497799835;
      "bitwarden" = 1352778147;
      "goodnotes" = 1444383602;
      "tailscale" = 1475387142;
      "wireguard" = 1451685025;
      "xcode" = 497799835;
    };

    strToPkg = name: getAttrFromPath (splitString "." name) pkgs;
  in {
    options.my.apps = mkOption {
      default = {};
      description = "Smart motor apps routing Nix, Casks, and Mac App Store";
      type = types.attrsOf (types.submodule {
        options = {
          enable = mkEnableOption "Activate group";
          level = mkOption {
            type = types.enum ["system" "user"];
            default = "system";
          };
          targetUser = mkOption {
            type = types.str;
            default = "nicolas";
          };
          apps = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of app names (e.g., [\"git\" \"docker\" \"slack\"])";
          };
        };
      });
    };

    config = let
      activeGroups = filterAttrs (_: g: g.enable) cfg;
      systemGroups = filterAttrs (_: g: g.level == "system") activeGroups;
      userGroups = filterAttrs (_: g: g.level == "user") activeGroups;

      sysAppsRaw = flatten (mapAttrsToList (_: g: g.apps) systemGroups);

      sysCasks =
        if isDarwin
        then filter (x: builtins.elem x macCasks) sysAppsRaw
        else [];

      sysMasAppsKeys =
        if isDarwin
        then filter (x: builtins.hasAttr x macMasApps) sysAppsRaw
        else [];
      sysMasApps = builtins.listToAttrs (map (name: {
          inherit name;
          value = macMasApps.${name};
        })
        sysMasAppsKeys);

      sysNixStrings =
        if isDarwin
        then filter (x: !(builtins.elem x macCasks) && !(builtins.hasAttr x macMasApps)) sysAppsRaw
        else sysAppsRaw;
      sysPackages = map strToPkg sysNixStrings;

      uniqueUsers = unique (mapAttrsToList (_: g: g.targetUser) userGroups);

      userPackagesConfig =
        foldl' (
          acc: user: let
            userAppsRaw = flatten (mapAttrsToList (_: g: g.apps) (filterAttrs (_: g: g.targetUser == user) userGroups));
            userNixStrings =
              if isDarwin
              then filter (x: !(builtins.elem x macCasks) && !(builtins.hasAttr x macMasApps)) userAppsRaw
              else userAppsRaw;
            userPkgs = map strToPkg userNixStrings;
          in
            acc
            // {
              ${user} = {
                home.packages = userPkgs;
              };
            }
        ) {}
        uniqueUsers;

      userCasksRaw = flatten (mapAttrsToList (_: g: g.apps) userGroups);
      userCasks =
        if isDarwin
        then filter (x: builtins.elem x macCasks) userCasksRaw
        else [];

      userMasAppsKeys =
        if isDarwin
        then filter (x: builtins.hasAttr x macMasApps) userCasksRaw
        else [];
      userMasApps = builtins.listToAttrs (map (name: {
          inherit name;
          value = macMasApps.${name};
        })
        userMasAppsKeys);
    in
      mkMerge [
        (mkIf (sysPackages != []) {
          environment.systemPackages = sysPackages;
        })

        (mkIf (isDarwin && (sysCasks != [] || userCasks != [] || sysMasApps != {} || userMasApps != {})) {
          homebrew.casks = sysCasks ++ userCasks;
          homebrew.masApps = sysMasApps // userMasApps;
        })

        (mkIf (userPackagesConfig != {}) {
          home-manager.users = userPackagesConfig;
        })
      ];
  };
}
