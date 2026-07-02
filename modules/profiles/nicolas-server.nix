{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.nicolas-server = {
    sops.secrets = {
      "profiles/nicolas-server/ssh/private_key" = {};
      "profiles/nicolas-server/gpg/private_key" = {};
      "profiles/nicolas-server/gpg/public_key" = {};
      "profiles/nicolas-server/gpg/key_id" = {};
    };

    my.userProfiles.nicolas-server.homeManager = {
      # pkgs,
      osConfig,
      ...
    }: {
      imports = [
        commonModules.home-secrets
        commonModules.git-identity
      ];

      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "nicolas-server-key";
              publicKey = osConfig.sops.secrets."profiles/nicolas-server/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/nicolas-server/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.nicolas-server = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId =
                osConfig.sops.secrets."profiles/nicolas-server/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."profiles/nicolas-server/ssh/private_key".path;
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
