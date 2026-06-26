{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.nicolas-bbook = {
    sops.secrets = {
      "profiles/nicolas-bbook/ssh/private_key" = {};
      "profiles/nicolas-bbook/gpg/private_key" = {};
      "profiles/nicolas-bbook/gpg/public_key" = {};
      "profiles/nicolas-bbook/gpg/key_id" = {};
    };

    homebrew.casks = [
      "firefox"
      "firefox-dev"
    ];

    my.userProfiles.nicolas-personal.homeManager = {
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
              publicKey = osConfig.sops.secrets."profiles/nicolas-bbook/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/nicolas-bbook/gpg/private_key".path;
            }
          ];
        };
        git-identiry = {
          enable = true;
          workspaces.nicolas-bbook = {
            directory = "~/Projects/Bbook";
            realName = "Nicolas Villarroel Martinez.";
            email = "nmartinez@bbook.cl";
            gpg = {
              enable = true;
              keyId = osConfig.sops.secrets."profiles/nicolas-bbook/gpg/key_id".path;
            };
            ssh = {
              enableAuht = true;
              privateKey = osConfig.sops.secrets."profiles/nicolas-bbook/ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
