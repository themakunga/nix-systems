{
  flake.profileModules.thoughtworks = {
    lib,
    pkgs,
    config,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
  in {
    sops.secrets = {
      "profiles/thouhtworks/ssh/private_key" = {};
      "profiles/thouhtworks/gpg/private_key" = {};
      "profiles/thouhtworks/gpg/public_key" = {};
      "profiles/thouhtworks/gpg/key_id" = {};
    };

    homebrew = mkIf isDarwin {
      casks = [
        "google-chrome"
      ];
    };

    my.userProfiles.nicolas-work.homeManager = {
      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "thoughtworks-key";
              publicKey = config.sops.secrets."profiles/thouhtworks/gpg/public_key".path;
              privateKey = config.sops.secrets."profiles/thouhtworks/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.thouhtworks = {
            directory = "~/Projects/Thoughtworks";
            realName = "Nicolas Villarroel";
            email = "nicolas.villarroel@thoughtworks.com";
            gpg = {
              enable = true;
              keyId = config.sops.secrets."profiles/thouhtworks/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = config.sops.secrets."profiles/thouhtworks/ssh/private_key".path;
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
