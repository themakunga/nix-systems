{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.homelab = {
    sops.secrets = {
      "ssh/homelab/private_key" = {};
      "gpg/homelab/private_key" = {};
      "gpg/homelab/public_key" = {};
    };

    my.userProfiles.glados.homehomelab = {
      # pkgs,
      osConfig,
      ...
    }: {
      imports = [
        commonModules.sops.gpg
      ];

      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "homelab-key";
              publicKey = osConfig.sops.secrets."gpg/homelab/public_key".path;
              privateKey = osConfig.sops.secrets."gpg/homelab/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.thouhtworks = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId = "nicolas.villarroel@homelab.com";
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."ssh/homelab/private_key".path;
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
