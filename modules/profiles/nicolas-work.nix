{self, ...}: let
  inherit (self) commonModules;
in {
  flake.profileModules.nicolas-work = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
  in {
    sops.secrets = {
      "profiles/nicolas-work/ssh/private_key" = {};
      "profiles/nicolas-work/gpg/private_key" = {};
      "profiles/nicolas-work/gpg/public_key" = {};
      "profiles/nicolas-work/gpg/key_id" = {};
    };

    homebrew = mkIf isDarwin {
      casks = [
        "firefox"
        "firefox-dev"
      ];
    };

    my.userProfiles.nicolas-work.homeManager = {
      # pkgs,
      osConfig,
      ...
    }: {
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
              name = "work-key";
              publicKey = osConfig.sops.secrets."profiles/nicolas-work/gpg/public_key".path;
              privateKey = osConfig.sops.secrets."profiles/nicolas-work/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.nicolas-work = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel Martinez.";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId =
                osConfig.sops.secrets."profiles/nicolas-work/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = osConfig.sops.secrets."profiles/nicolas-work/ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
