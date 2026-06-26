{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.nicolas-admin = {
    sops.secrets = {
      "profiles/nicolas-admin/ssh/private_key" = {};
      "profiles/nicolas-admin/gpg/private_key" = {};
      "profiles/nicolas-admin/gpg/public_key" = {};
      "profiles/nicolas-admin/gpg/key_id" = {};
    };

    my.userProfiles.nicolas-admin.homeManager = {
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
              name = "admin-key";
              publicKey = osConfig.sops.secrets."profiles/nicolas-admin/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/nicola-admin/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.nicolas-admin = {
            directory = "~/Repositories";
            realName = "Nicolas Villarroel Martinez.";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId =
                osConfig.sops.secrets."profiles/nicolas-admin/gpg/key_id".path;
            };
            ssh = {
              enableAuht = true;
              privateKey = osConfig.sops.secrets."profiles/nicolas-admin/ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
