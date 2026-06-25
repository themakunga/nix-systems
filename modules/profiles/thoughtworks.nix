{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.thoughtworks = {
    sops.secrets = {
      "ssh/thoughtworks/private_key" = {};
      "gpg/thoughtworks/private_key" = {};
      "gpg/thoughtworks/public_key" = {};
    };

    homebrew.casks = [
      "google-chrome"
    ];

    my.userProfiles.work.homeManager = {
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
              name = "thoughtworks-key";
              publicKey = osConfig.sops.secrets."gpg/thoughtworks/public_key".path;
              privateKey = osConfig.sops.secrets."gpg/thoughtworks/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.thouhtworks = {
            directory = "~/Projects/Thoughtworks";
            realName = "Nicolas Villarroel";
            email = "nicolas.villarroel@thoughtworks.com";
            gpg = {
              enable = true;
              keyId = "nicolas.villarroel@thoughtworks.com";
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."ssh/thoughtworks/private_key".path;
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
