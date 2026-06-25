{
  flake.commonModules.authorizedKeys = {
    config,
    lib,
    ...
  }: let
    inherit
      (lib)
      mkOption
      types
      mkEnableOption
      mkIf
      removeSuffix
      genAttrs
      ;
    inherit
      (types)
      str
      path
      listOf
      nullOr
      either
      ;
    inherit
      (builtins)
      attrNames
      readDir
      readFile
      ;
    cfg = config.my.authorizedKeys;
  in {
    options.my.authorizedKeys = {
      enable = mkEnableOption "Assign public SSH keys from a directory";

      keysDir = mkOption {
        type = nullOr path;
        default = null;
        description = "Path for public keys path";
      };
      keys = mkOption {
        type = nullOr (listOf str);
        default = null;
        description = "List of keys to assign to host";
      };
      keysFiles = mkOption {
        type = nullOr (listOf (either path str));
        default = null;
        description = "List of path keys";
      };

      assignTo = mkOption {
        type = listOf str;
        default = [];
        description = "List of profiles/user to assign key/s";
      };
    };

    config = mkIf cfg.enable {
      users.users = genAttrs cfg.assignTo (userName: {
        openssh.authorizedKeys.keys = let
          dirKeys =
            if cfg.keysDir != null
            then let
              keyFilesList = attrNames (readDir cfg.keysDir);
            in
              map (file: removeSuffix "\n" (readFile "${cfg.keysDir}/${file}")) keyFilesList
            else [];
          safeKeys =
            if cfg.keys != null
            then cfg.keys
            else [];
        in
          dirKeys ++ safeKeys;

        openssh.authorizedKeys.keyFiles =
          if cfg.keysFiles != null
          then cfg.keysFiles
          else [];
      });
    };
  };
}
