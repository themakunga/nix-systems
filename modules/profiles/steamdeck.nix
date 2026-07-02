{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.steamdeck = {
    sops.secrets = {
      "profiles/steamdeck/ssh/private_key" = {};
      "profiles/steamdeck/gpg/private_key" = {};
      "profiles/steamdeck/gpg/public_key" = {};
      "profiles/steamdeck/gpg/key_id" = {};
    };

    my.userProfiles.deck.homeManager = {
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
              name = "steamdeck-key";
              publicKey = osConfig.sops.secrets."profiles/steamdeck/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/steamdeck/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.steamdeck = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId = osConfig.sops.secrets."profiles/steamdeck/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."profiles/steamdeck/ssh/private_key".path;
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
