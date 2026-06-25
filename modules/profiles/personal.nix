{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.personal = {
    sops.secrets = {
      "ssh/personal/private_key" = {};
      "gpg/personal/private_key" = {};
      "gpg/personal/public_key" = {};
    };

    homebrew.casks = [
      "firefox"
      "firefox-dev"
    ];

    my.userProfiles.me.homeManager = {
      # pkgs,
      osConfig,
      ...
    }: {
      imports = [
        commonModules.git-identity
      ];

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };

      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "personal-key";
              publicKey = osConfig.sops.secrets."gpg/personal/public_key".path;
              privateKey = osConfig.sops.secrets."gpg/personal/private_key".path;
            }
          ];
        };
        git-identiry = {
          enable = true;
          workspaces.personal = {
            directory = "~/Projects/Personal";
            realName = "Nicolas Villarroel Martinez.";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId = "nmartinezv@icloud.com";
            };
            ssh = {
              enableAuht = true;
              privateKey = osConfig.sops.secrets."ssh/personal/private_key".path;
            };
          };
        };
      };
    };
  };
}
