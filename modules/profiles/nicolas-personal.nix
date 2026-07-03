{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.nicolas-personal = {
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
  in {
    sops.secrets = {
      "profiles/nicolas-personal/ssh/private_key" = {};
      "profiles/nicolas-personal/gpg/private_key" = {};
      "profiles/nicolas-personal/gpg/public_key" = {};
      "profiles/nicolas-personal/gpg/key_id" = {};
    };

    homebrew = mkIf isDarwin {
      casks = [
        "firefox"
        "firefox-dev"
      ];
    };

    my.userProfiles.nicolas-personal.homeManager = {osConfig, ...}: {
      imports = [
        commonModules.home-secrets
        commonModules.git-identity
      ];

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };

      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "personal-key";
              publicKey = osConfig.sops.secrets."profiles/nicolas-personal/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/nicolas-personal/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.nicolas-personal = {
            directory = "~/Projects/Personal";
            realName = "Nicolas Villarroel Martinez.";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId =
                osConfig.sops.secrets."profiles/nicolas-personal/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."profiles/nicolas-personal/ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
