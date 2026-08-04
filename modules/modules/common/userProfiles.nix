# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
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
      either
      package
      listOf
      ;
  in {
    options.my.userProfiles = mkOption {
      default = {};
      type = attrsOf (
        submodule (
          {name, ...}: {
            options = {
              username = mkOption {
                type = str;
                default = name;
              };
              fullName = mkOption {
                type = str;
                default = "";
              };
              email = mkOption {
                type = str;
                default = "";
              };
              description = mkOption {
                type = str;
                default = "";
              };
              isSystem = mkOption {
                type = bool;
                default = false;
              };
              createHome = mkOption {
                type = bool;
                default = true;
              };
              isAdmin = mkOption {
                type = bool;
                default = false;
              };
              isNetworkManager = mkOption {
                type = bool;
                default = false;
              };
              extraGroups = mkOption {
                type = listOf str;
                default = [];
              };
              shell = mkOption {
                type = either package str;
                default = pkgs.bashInteractive;
              };
              hashedPasswordFile = mkOption {
                type = nullOr str;
                default = null;
              };
            };
          }
        )
      );
    };

    config = mkIf (cfg != {}) {
      users.users =
        mapAttrs' (
          _: userCfg:
            nameValuePair userCfg.username (
              {
                description =
                  if userCfg.fullName != ""
                  then userCfg.fullName
                  else userCfg.description;
                inherit (userCfg) shell;
                home =
                  if userCfg.isSystem
                  then "/opt/${userCfg.username}"
                  else if isDarwin
                  then "/Users/${userCfg.username}"
                  else "/home/${userCfg.username}";
              }
              // optionalAttrs isLinux {
                inherit (userCfg) hashedPasswordFile createHome;
                isNormalUser = !userCfg.isSystem;
                isSystemUser = userCfg.isSystem;
                group = userCfg.username;
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
        mapAttrs' (_: userCfg: nameValuePair userCfg.username {}) cfg
      );
    };
  };
}
