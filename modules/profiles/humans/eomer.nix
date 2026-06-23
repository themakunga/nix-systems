{
  self,
  ...
}:
let
  inherit (self) commonModules;
in
{
  flake.profileModules.eomer = {
    # darwin = { ... }: { };

    user =
      { config, ... }:
      {
        imports = [
          commonModules.sops.shared-secrets
          commonModules.git-identity
        ];

        sops.secrets = {
          "ssh/grainger/private_key" = { };
          "gpg/grainger/private_key" = { };
          "gpg/grainger/public_key" = { };
        };

        programs = {
          sops.gpg = {
            enable = true;
            keys = [
              {
                name = "Eomer";
                privateKey = config.sops.secrets."gpg/grainger/private_key".path;
                publicKey = config.sops.secrets."gpg/grainger/public_key".path;
              }
            ];
          };
          git-identiry = {
            workspaces.eomer = {
              directory = "~/Projects/Grainger";
              realName = "Nicolas Villarroel";
              email = "nicolas.villarroel1@grainger.com";
              gpg = {
                enable = true;
                key = "nicolas.villarroel1@grainger.com";
              };
              ssh = {
                enableAuth = true;
                privateKeyPath = config.sops.secrets."ssh/grainger/private_key".path;
              };
            };
          };
        };
      };
  };

}
