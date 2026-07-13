{
  flake.profileModules.thoughtworks = {config, ...}: {
    sops.secrets = {
      "profiles/thouhtworks/ssh/private_key" = {};
      "profiles/thouhtworks/gpg/private_key" = {};
      "profiles/thouhtworks/gpg/public_key" = {};
      "profiles/thouhtworks/gpg/key_id" = {};
    };

    my = {
      apps = {
        tw = {
          enable = true;
          level = "user";
          targetUser = "nicolas";
          apps = [
            "google-chrome"
            "zoom"
            "figma"
          ];
        };
      };
      gh.thoughtworks.enable = true;
      userProfiles.nicolas-work.homeManager = {
        programs = {
          sops.gpg = {
            enable = true;
            keys = [
              {
                name = "thoughtworks-key";
                publicKey = config.sops.secrets."profiles/thouhtworks/gpg/public_key".path;
                privateKey = config.sops.secrets."profiles/thouhtworks/gpg/private_key".path;
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
                keyId = config.sops.secrets."profiles/thouhtworks/gpg/key_id".path;
              };
              ssh = {
                enableAuth = true;
                privateKey = config.sops.secrets."profiles/thouhtworks/ssh/private_key".path;
              };
            };
          };
        };

        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
        };
      };
    };
  };
}
