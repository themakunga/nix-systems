{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.bbook = {
    sops.secrets = {
      "ssh/bbook/private_key" = {};
      "gpg/bbook/private_key" = {};
      "gpg/bbook/public_key" = {};
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
              name = "bbook-key";
              publicKey = osConfig.sops.secrets."gpg/bbook/public_key".path;
              privateKey = osConfig.sops.secrets."gpg/bbook/private_key".path;
            }
          ];
        };
        git-identiry = {
          enable = true;
          workspaces.bbook = {
            directory = "~/Projects/Bbook";
            realName = "Nicolas Villarroel Martinez.";
            email = "nmartinez@bbook.cl";
            gpg = {
              enable = true;
              keyId = "nicolas@42devs.cl";
            };
            ssh = {
              enableAuht = true;
              privateKey = osConfig.sops.secrets."ssh/bbook/private_key".path;
            };
          };
        };
      };
    };
  };
}
