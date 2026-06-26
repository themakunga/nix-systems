{
  flake.userModules.nicolas-pihole = {config, ...}: {
    sops.secrets."passwords/pihole/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-pihole = {
      username = "pihole";
      description = "PiHole - server manager account";
      isSystem = true;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/pihole/hashed".path;
      extraGroups = ["docker"];
    };
  };
}
