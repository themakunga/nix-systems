{
  flake.userModules.media = {
    my.userProfiles.media = {
      username = "media";
      description = "Media Server User - own config";
      isSystem = true;
      isAdmin = false;
      isNetworkManager = true;
      extraGroups = ["docker"];
      createHome = true;
    };
  };
}
