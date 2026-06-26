{
  flake.userModules.nicolas-admin = {config, ...}: {
    sops.secrets."passwords/nicolas-admin/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.me = {
      username = "nicolas";
      description = "Nicolas - admin manager account";
      isSystem = true;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/nicolas-admin/hashed".path;
      extraGroups = ["docker"];
    };
  };
}
