{
  flake.userModules.me = {config, ...}: {
    sops.secrets."passwords/personal/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.me = {
      username = "nicolas";
      description = "Personal Account - Main to use";
      isSystem = false;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/personal/hashed".path;
      extraGroups = ["docker"];
    };
  };
}
