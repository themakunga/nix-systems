{
  self,
  ...
}:
let
  inherit (self) commonModules;
in
{
  flake.profileModules.eowyn = {
    # darwin = {...}: {};

    user =
      { config, ... }:
      {
        imports = [
          commonModules.sops.shared-secrets
          commonModules.git-identity
        ];

        sops.secrets = {
          "ssh/thoughtworks/private_key" = { };
          "gpg/thoughtworks/private_key" = { };
          "gpg/thoughtworks/public_key" = { };
        };

        programs = {
          sops.gpg = {
            enable = true;
            keys = [
              {
                name = "Eowyn";
                privateKey = config.sops.secrets."gpg/thoughtworks/private_key".path;
                publicKey = config.sops.secrets."gpg/thoughtworks/public_key".path;
              }
            ];
          };
          git-identity = {
            workspaces.eowyn = {
              directory = "~/Projects/Thoughtworks/";
              realName = "Nicolas Villarroel M";
              email = "nicolas.villarroel@thoughtworks.com";
              gpg = {
                enable = true;
                key = "nicolas.villarroel@thoughtworks.com";
              };
              ssh = {
                enableAuth = true;
                privateKeyPath = config.sops.secrets."ssh/thoughtworks/private_key".path;
              };
            };
          };
        };

      };
  };
}
