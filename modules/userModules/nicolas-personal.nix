{
  flake.userModules.me = {config, ...}: {
    sops.secrets."passwords/nicolas/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-personal = {
      username = "nicolas";
      description = "Personal Account - Main to use";
      isSystem = false;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/nicolas/hashed".path;
      extraGroups = ["docker"];
    };
  };
}
