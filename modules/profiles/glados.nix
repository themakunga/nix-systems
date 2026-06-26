{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.glados = {
    sops.secrets = {
      "profiles/glados/ssh/private_key" = {};
      "profiles/glados/gpg/private_key" = {};
      "profiles/glados/gpg/public_key" = {};
      "profiles/glados/gpg/key_id" = {};
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
              name = "glados-key";
              publicKey = osConfig.sops.secrets."profiles/glados/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/glados/gpg/private_key".path;
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
              keyId = osConfig.sops.secrets."profiles/glados/gpg/key_id";
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."profiles/glados/ssh/private_key".path;
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
