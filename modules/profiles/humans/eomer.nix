# {
#   self,
#   inputs,
#   ...
# }:
{
  flake.profileModules.eomer = {
    # system = {...}: {};
    # darwin = {...}: {};

    user = {config, ...}: {
      sops.secrets = {
        "ssh/grainger/private_key" = {};
        "gpg/grainger/private_key" = {};
        "gpg/grainger/public_key" = {};
      };

      programs.sops.gpg = {
        enable = true;
        keys = [
          {
            name = "Grainger Identity";
            publicKey = config.sops.secrets."gpg/grainger/public_key".path;
            privateKey = config.sops.secrets."gpg/grainger/private_key".path;
          }
        ];
      };

      programs.git-identity = {
        workspaces.grainger = {
          directory = "~/Projects/Grainger"; # Ajusta la ruta a tu entorno real
          realName = "Nicolas Villarroel";
          email = "nicolas.villarroel1@grainger.com";
          gpg = {
            enable = true;
            keyId = "nicolas.villaroel1@grainger.com"; # O el keyId alfanumérico
          };
          ssh = {
            enableAuth = true;
            privateKeyPath = config.sops.secrets."ssh/grainger/private_key".path;
          };
        };
      };
    };
  };
}
