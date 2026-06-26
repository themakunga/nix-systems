{
  flake.userModules.deck = {
    my.userProfiles.deck = {
      username = "deck";
      description = "Handheald awsewemesd";
      isSystem = true;
      isAdmin = false;
      isNetworkManager = true;
      extraGroups = ["docker"];
      createHome = true;
    };
  };
}
