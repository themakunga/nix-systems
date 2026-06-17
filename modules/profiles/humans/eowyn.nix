# {
#   self,
#   inputs,
#   ...
# }:
{
  flake.profileModules.eowyn = {
    # system = {...}: {};
    # darwin = {...}: {};

    user = {config, ...}: {
      sops.secrets = {
        "ssh/thoughtworks/private_key" = {};
        "gpg/thoughtworks/private_key" = {};
        "gpg/thoughtworks/public_key" = {};
      };

      programs.sops.gpg = {
        enable = true;
        keys = [
          {
            name = "Thoughtworks Identity";
            publicKey = config.sops.secrets."gpg/thoughtworks/public_key".path;
            privateKey = config.sops.secrets."gpg/thoughtworks/private_key".path;
          }
        ];
      };

      programs.git-identity = {
        workspaces.thoughtworks = {
          directory = "~/Projects/Thoughtworks"; # Ajusta la ruta a tu entorno real
          realName = "Nicolas Villarroel Martinez";
          email = "nicolas.villarroel@thoughtworks.com";
          gpg = {
            enable = true;
            keyId = "nicolas.villarroel@thoughtworks.com"; # O el keyId alfanumérico
          };
          ssh = {
            enableAuth = true;
            privateKeyPath = config.sops.secrets."ssh/thoughtworks/private_key".path;
          };
        };
      };
    };
  };
}
