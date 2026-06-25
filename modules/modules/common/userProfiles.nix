{
  flake.commonModules.userProfiles = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.my.userProfiles;
    inherit (pkgs.stdenv.hostPlatform) isLinux isDarwin;
    inherit
      (lib)
      mkIf
      types
      mkOption
      mapAttrs'
      optionalAttrs
      optionals
      nameValuePair
      ;
    inherit
      (types)
      str
      attrsOf
      submodule
      bool
      nullOr
      listOf
      package
      unspecified
      ;
  in {
    options.my.userProfiles = mkOption {
      description = "Dinamyc user profile";
      default = {};
      type = attrsOf (
        submodule (
          {name, ...}: {
            options = {
              username = mkOption {
                type = str;
                default = name;
                description = "login username";
              };
              description = mkOption {
                type = str;
                default = "";
              };
              isSystem = mkOption {
                type = bool;
                default = false;
                description = "If the user is sys level";
              };
              createHome = mkOption {
                type = bool;
                default = true;
                description = "Create user home directory";
              };
              isAdmin = mkOption {
                type = bool;
                default = false;
                description = "If user is admin / sudo permission";
              };
              isNetworkManager = mkOption {
                type = bool;
                default = false;
                description = "If the user is nertworking manager";
              };
              extraGroups = mkOption {
                type = listOf str;
                default = [];
                description = "Additional groups for the user";
              };
              shell = mkOption {
                type = nullOr package;
                default = pkgs.bashInteractive;
              };
              hashedPasswordFile = mkOption {
                type = nullOr str;
                default = null;
                description = "Path for hashed password";
              };
              homeManager = mkOption {
                type = unspecified;
                default = {};
                description = "Home Manager configuration module or attrset";
              };
            };
          }
        )
      );
    };

    config = mkIf (cfg != {}) {
      users.users =
        mapAttrs' (
          profileName: userCfg:
            nameValuePair userCfg.username (
              {
                inherit (userCfg) description shell hashedPasswordFile;

                home =
                  if userCfg.isSystem
                  then "/opt/${userCfg.username}"
                  else if isDarwin
                  then "/Users/${userCfg.username}"
                  else "/home/${userCfg.username}";
              }
              // optionalAttrs isLinux {
                isNormalUser = !userCfg.isSystem;
                isSystemUser = userCfg.isSystem;
                group = userCfg.username;
                inherit (userCfg) createHome;
                extraGroups =
                  userCfg.extraGroups
                  ++ optionals userCfg.isAdmin [
                    "wheel"
                  ]
                  ++ optionals userCfg.isNetworkManager [
                    "networkmanager"
                  ];
              }
              // optionalAttrs isDarwin {
                isHidden = userCfg.isSystem;
                inherit (userCfg) createHome;
              }
            )
        )
        cfg;

      users.groups = optionalAttrs isLinux (
        mapAttrs' (profileName: userCfg: nameValuePair userCfg.username {}) cfg
      );

      home-manager.users =
        mapAttrs' (
          profileName: userCfg: nameValuePair userCfg.username userCfg.homeManager
        )
        cfg;
    };
  };
}
