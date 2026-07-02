{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.grainger = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
  in {
    sops.secrets = {
      "profiles/grainger/ssh/private_key" = {};
      "profiles/grainger/gpg/private_key" = {};
      "profiles/grainger/gpg/public_key" = {};
      "profiles/grainger/gpg/key_id" = {};
    };
    homebrew = mkIf isDarwin {
      casks = [
        "microsoft-teams"
        "slack"
        "dbeaver-community"
      ];
    };

    my.userProfiles.nicolas-work.homeManager = {osConfig, ...}: {
      imports = [
        commonModules.home-secrets
        commonModules.git-identity
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
