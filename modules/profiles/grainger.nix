{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.grainger = {
    sops.secrets = {
      "ssh/grainger/private_key" = {};
      "gpg/grainger/private_key" = {};
      "gpg/grainger/public_key" = {};
    };

    my.userProfile.work.homeManager = {
      pkgs,
      osConfig,
      ...
    }: {
      imports = [
        commonModules.git-identity
      ];

      homebrew.casks = [
        "microsoft-teams"
        "slack"
        "dbeaver-community"
      ];

      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "grainger-key";
              publicKey = osConfig.sops.secrets."gpg/grainger/public_key".path;
              privateKey = osConfig.sops.secrets."gpg/grainger/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.grainger = {
            directory = "~/Projects/Grainger";
            realName = "Villarroel, Nicolas";
            email = "nicolas.villarroel1@grainger.com";
            gpg = {
              enable = true;
              keyId = "nicolas.villarroel1@grainger.com";
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."ssh/grainger/private_key".path;
            };
          };
        };
      };

      home.packages = with pkgs; [
        awscli2
      ];

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };
    };
  };
}
