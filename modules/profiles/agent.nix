{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.agent = {
    sops.secrets = {
      "ssh/agent/private_key" = {};
      "gpg/agent/private_key" = {};
      "gpg/agent/public_key" = {};
    };

    my.userProfiles.glados.homeManager = {
      # pkgs,
      osConfig,
      ...
    }: {
      imports = [
        commonModules.git-identity
      ];

      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "agent-key";
              publicKey = osConfig.sops.secrets."gpg/agent/public_key".path;
              privateKey = osConfig.sops.secrets."gpg/agent/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.agent = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId = "nicolas.villarroel@agent.com";
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."ssh/agent/private_key".path;
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
