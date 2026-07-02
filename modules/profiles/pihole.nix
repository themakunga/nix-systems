{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.pihole = {
    sops.secrets = {
      "profiles/nicolas-pihole/ssh/private_key" = {};
      "profiles/nicolas-pihole/gpg/private_key" = {};
      "profiles/nicolas-pihole/gpg/public_key" = {};
      "profiles/nicolas-pihole/gpg/key_id" = {};
    };

    my.userProfiles.pihole.homeManager = {
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
              name = "pihole-key";
              publicKey = osConfig.sops.secrets."profiles/nicolas-pihole/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/nicolas-pihole/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.pihole = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId =
                osConfig.sops.secrets."profiles/nicolas-pihole/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."profiles/nicolas-pihole/ssh/private_key".path;
            };
          };
        };
      };

      # home.packages = with pkgs; [ ];

      services.gpg-pihole = {
        enable = true;
        enableSshSupport = true;
      };
    };
  };
}
