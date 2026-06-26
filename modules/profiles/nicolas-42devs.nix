{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.nicolas-42devs = {
    sops.secrets = {
      "profiles/nicolas-42devs/ssh/private_key" = {};
      "profiles/nicolas-42devs/gpg/private_key" = {};
      "profiles/nicolas-42devs/gpg/public_key" = {};
      "profiles/nicolas-42devs/gpg/key_id" = {};
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
              publicKey = osConfig.sops.secrets."profiles/nicolas-42devs/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/nicolas-42devs/gpg/private_key".path;
            }
          ];
        };
        git-identiry = {
          enable = true;
          workspaces.nicolas-42devs = {
            directory = "~/Projects/42Devs";
            realName = "Nicolas Villarroel Martinez.";
            email = "nicolas@42devs.cl";
            gpg = {
              enable = true;
              keyId =
                osConfig.sops.secrets."profiles/nicolas-42devs/gpg/key_id".path;
            };
            ssh = {
              enableAuht = true;
              privateKey = osConfig.sops.secrets."profiles/nicolas-42devs/ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
