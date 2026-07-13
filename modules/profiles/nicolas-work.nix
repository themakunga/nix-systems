{
  flake.profileModules.nicolas-work = {config, ...}: {
    sops.secrets = {
      "profiles/nicolas-work/ssh/private_key" = {};
      "profiles/nicolas-work/gpg/private_key" = {};
      "profiles/nicolas-work/gpg/public_key" = {};
      "profiles/nicolas-work/gpg/key_id" = {};
    };

    my = {
      apps = {
        base = {
          enable = true;
          level = "user";
          targetUser = "nicolas";
          apps = [
            "typora"
            "Termius"
          ];
        };
        personal = {
          enable = true;
          level = "user";
          targetUser = "nicolas";
          apps = [
            "Whatsapp Messenger"
            "awscli2"
            "discord"
            "goodnotes"
            "nchat"
            "obsidian"
            "qmk-toolbox"
            "steam"
            "via"
          ];
        };
      };

      userProfiles.nicolas-work.homeManager = {
        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
        };

        programs = {
          sops.gpg = {
            enable = true;
            keys = [
              {
                name = "work-key";
                publicKey = config.sops.secrets."profiles/nicolas-work/gpg/public_key".path;
                privateKey = config.sops.secrets."profiles/nicolas-work/gpg/private_key".path;
              }
            ];
          };
          git-identity = {
            enable = true;
            workspaces.nicolas-work = {
              directory = "~/Projects";
              realName = "Nicolas Villarroel Martinez.";
              email = "nmartinezv@icloud.com";
              gpg = {
                enable = true;
                keyId =
                  config.sops.secrets."profiles/nicolas-work/gpg/key_id".path;
              };
              ssh = {
                enableAuth = true;
                privateKey = config.sops.secrets."profiles/nicolas-work/ssh/private_key".path;
              };
            };
          };
        };
      };
    };
  };
}
