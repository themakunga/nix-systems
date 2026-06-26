{
  flake.userModules.work = {config, ...}: {
    sops.secrets."passwords/nicolas/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.work = {
      username = "nicolas";
      description = "Work Account - To user in work pc/mac";
      isSystem = false;
      isAdmin = true;
      isNetworkManager = false;
      hashedPaswordFile = config.sops.secrets."passwords/nicolas/hashed".path;
    };
  };
}
