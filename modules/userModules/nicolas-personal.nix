{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.nicolas-personal = {config, ...}: {
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
