{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.deck = {
    my.userProfiles.deck = {
      username = "deck";
      description = "Handheald awsewemesd";
      isSystem = true;
      isAdmin = false;
      isNetworkManager = true;
      extraGroups = ["docker"];
      createHome = true;

      homeManager = {
        imports = [
          commonModules.home-secrets
          commonModules.git-identity
        ];

        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
        };
      };
    };
  };
}
