{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.mediacenter = {
    sops.secrets = {
      "ssh/mediacenter/private_key" = {};
      "gpg/mediacenter/private_key" = {};
      "gpg/mediacenter/public_key" = {};
    };

    my.userProfiles.glados.homeManager = {
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
              name = "mediacenter-key";
              publicKey = osConfig.sops.secrets."gpg/mediacenter/public_key".path;
              privateKey = osConfig.sops.secrets."gpg/mediacenter/private_key".path;
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
              keyId = "nicolas.villarroel@mediacenter.com";
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."ssh/mediacenter/private_key".path;
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
