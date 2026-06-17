# {
#   self,
#   inputs,
#   ...
# }:
{
  flake.profileModules.galadriel = {
    system = {pkgs, ...}: {
      users = {
        groups.galadriel = {};
        users.galadriel = {
          description = "Galadriel - IA User";
          isSystemUser = true;
          group = "galadriel";
          home = "/opt/galadiel";
          createHome = true;

          shell = pkgs.writeShellScriptBin "nologin" ''
            echo "This is only a service account. Access Denied."
            exit 1
          '';
        };
      };
    };
    # darwin = { ... }: { };
    user = {config, ...}: {
      sops.secrets = {
        "ssh/galadriel/private_key" = {};
        "gpg/galadriel/private_key" = {};
        "gpg/galadriel/public_key" = {};
      };

      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "Galadriel";
              publicKey = config.sops.secrets."gpg/galadirel/public_key".path;
              privateKey = config.sops.secrets."gpg/galadriel/private_key".path;
            }
          ];
        };
        git-identity = {
          workspace.galadriel = {
            directory = "/opt/galadriel/repositories";
            realName = "Galadiel";
            email = "galadriel@rivendell.local";
            gpg = {
              enable = true;
              keyId = "galadriel@rivendell.local";
            };
            ssh = {
              enableAuth = true;
              privateKeyPath = config.sops.secrets."ssh/galadriel/private_key".path;
            };
          };
        };
      };
    };
  };
}
