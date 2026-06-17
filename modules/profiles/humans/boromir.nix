# {
#   inputs,
#   self,
#   ...
# }:
{
  flake.profileModules.boromir = {
    # system = {...}: {};
    # darwin = {...}: {};

    user = {config, ...}: {
      sops.secrets = {
        "ssh/42devs/private_key" = {};
        "gpg/42devs/private_key" = {};
        "gpg/42devs/public_key" = {};
      };

      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "Nicolas Villarroel Martinez.";
              publicKey = config.sops.secrets."gpg/42devs/public_key".path;
              privateKey = config.sops.secrets."gpg/42devs/private_key".path;
            }
          ];
        };
        git-identity = {
          workspace.boromir = {
            directory = "~/Projects/42devs";
            realName = "Nicolas Villarroel Martinez.";
            email = "nicolas@42devs.cl";
            gpg = {
              enable = true;
              keyId = "nicolas@42devs.cl";
            };
            ssh = {
              enableAuth = true;
              privateKeyPath = config.sops.secrets."ssh/42devs/private_key".path;
            };
          };
        };
      };
    };
  };
}
