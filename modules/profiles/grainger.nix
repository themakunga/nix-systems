{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.grainger = {
    sops.secrets = {
      "profiles/grainger/ssh/private_key" = {};
      "profiles/grainger/gpg/private_key" = {};
      "profiles/grainger/gpg/public_key" = {};
      "profiles/grainger/gpg/key_id" = {};
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
              publicKey = osConfig.sops.secrets."profiles/grainger/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/grainger/gpg/private_key".path;
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
              keyId = osConfig.sops.secrets."profiles/grainger/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."profiles/grainger/ssh/private_key".path;
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
