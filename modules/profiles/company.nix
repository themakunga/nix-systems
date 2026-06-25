{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.company = {
    sops.secrets = {
      "ssh/company/private_key" = {};
      "gpg/company/private_key" = {};
      "gpg/company/public_key" = {};
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
              name = "company-key";
              publicKey = osConfig.sops.secrets."gpg/company/public_key".path;
              privateKey = osConfig.sops.secrets."gpg/company/private_key".path;
            }
          ];
        };
        git-identiry = {
          enable = true;
          workspaces.company = {
            directory = "~/Projects/42Devs";
            realName = "Nicolas Villarroel Martinez.";
            email = "nicolas@42devs.cl";
            gpg = {
              enable = true;
              keyId = "nicolas@42devs.cl";
            };
            ssh = {
              enableAuht = true;
              privateKey = osConfig.sops.secrets."ssh/company/private_key".path;
            };
          };
        };
      };
    };
  };
}
