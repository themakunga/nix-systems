{
  flake.profileModules.mediaserver = {
    sops.secrets = {
      "profiles/mediaserver/ssh/private_key" = {};
      "profiles/mediaserver/gpg/private_key" = {};
      "profiles/mediaserver/gpg/public_key" = {};
      "profiles/mediaserver/gpg/key_id" = {};
    };

    my.userProfiles.media.homeManager = {
      # pkgs,
      config,
      ...
    }: {
      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "mediaserver-key";
              publicKey = config.sops.secrets."profiles/mediaserver/gpg/public_key".path;
              privateKey = config.sops.secrets."profiles/mediaserver/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.mediaserver = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId =
                config.sops.secrets."profiles/mediaserver/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = config.sops.secrets."profiles/mediaserver/ssh/private_key".path;
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
