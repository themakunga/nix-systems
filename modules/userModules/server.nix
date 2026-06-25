{
  flake.userModules.server = {config, ...}: {
    sops.secrets."passwords/server/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.me = {
      username = "admin";
      description = "server - server manager account";
      isSystem = true;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/server/hashed".path;
      extraGroups = ["docker"];
    };
  };
}
