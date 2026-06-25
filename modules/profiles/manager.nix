{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.manager = {
    sops.secrets = {
      "ssh/manager/private_key" = {};
      "gpg/manager/private_key" = {};
      "gpg/manager/public_key" = {};
    };

    my.userProfiles.server.homeManager = {
      # pkgs,
      osConfig,
      ...
    }: {
      imports = [
        commonModules.git-identity
      ];

      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "manager-key";
              publicKey = osConfig.sops.secrets."gpg/manager/public_key".path;
              privateKey = osConfig.sops.secrets."gpg/manager/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.thouhtworks = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId = "nicolas.villarroel@manager.com";
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."ssh/manager/private_key".path;
            };
          };
        };
      };

      # home.packages = with pkgs; [ ];

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };
    };
  };
}
