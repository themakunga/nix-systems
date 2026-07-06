{self, ...}: let
  inherit (self) commonModules;
in {
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
}
