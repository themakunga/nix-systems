{
  flake.userModules.admin = {config, ...}: {
    sops.secrets."passwords/admin/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.me = {
      username = "admin";
      description = "admin - admin manager account";
      isSystem = true;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/admin/hashed".path;
      extraGroups = ["docker"];
    };
  };
}
