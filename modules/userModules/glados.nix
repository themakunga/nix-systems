{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.glados = {
    my.userProfiles.glados = {
      username = "glados";
      description = "Aperture Science Core AI - absolutelly not evil";
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
