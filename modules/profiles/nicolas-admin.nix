{
  flake.profileModules.nicolas-admin = {config, ...}: {
    sops.secrets = {
      "profiles/nicolas-admin/ssh/private_key" = {};
      "profiles/nicolas-admin/gpg/private_key" = {};
      "profiles/nicolas-admin/gpg/public_key" = {};
      "profiles/nicolas-admin/gpg/key_id" = {};
    };

    my.userProfiles.nicolas-admin.homeManager = {
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
              publicKey = config.sops.secrets."profiles/nicolas-admin/gpg/public_key".path;
              privateKey = config.sops.secrets."profiles/nicolas-admin/gpg/private_key".path;
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
                config.sops.secrets."profiles/nicolas-admin/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = config.sops.secrets."profiles/nicolas-admin/ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
