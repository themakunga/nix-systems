{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.nicolas-personal = {
    sops.secrets = {
      "profiles/nicolas-personal/ssh/private_key" = {};
      "profiles/nicolas-personal/gpg/private_key" = {};
      "profiles/nicolas-personal/gpg/public_key" = {};
      "profiles/nicolas-personal/gpg/key_id" = {};
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
              publicKey = osConfig.sops.secrets."profiles/nicolas-personal/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/nicola-personal/gpg/private_key".path;
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
              keyId =
                osConfig.sops.secrets."profiles/nicolas-personal/gpg/key_id".path;
            };
            ssh = {
              enableAuht = true;
              privateKey = osConfig.sops.secrets."profiles/nicolas-personal/ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
