{
  flake.profileModules.glados = {config, ...}: {
    sops.secrets = {
      "profiles/glados/ssh/private_key" = {};
      "profiles/glados/gpg/private_key" = {};
      "profiles/glados/gpg/public_key" = {};
      "profiles/glados/gpg/key_id" = {};
    };

    my.userProfiles.glados.homeManager = {
      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "glados-key";
              publicKey = config.sops.secrets."profiles/glados/gpg/public_key".path;
              privateKey = config.sops.secrets."profiles/glados/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.glados = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId = config.sops.secrets."profiles/glados/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = config.sops.secrets."profiles/glados/ssh/private_key".path;
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
