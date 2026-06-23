{
  self,
  ...
}:
let
  inherit (self) commonModules;
in
{
  flake.profileModules.faramir = {
    user =
      { config, ... }:
      {
        imports = [
          commonModules.git-identity
          commonModules.sops.shared-secrets
        ];

        sops.secrets = {
          "ssh/faramir/private_key" = { };
          "gpg/faramir/private_key" = { };
          "gpg/faramir/public_key" = { };
        };

        programs = {
          sops.gpg = {
            enable = true;
            keys = [
              {
                name = "Nicolas Villarroel Martinez.";
                publicKey = config.sops.secrets."gpg/faramir/public_key".path;
                privateKey = config.sops.secrets."gpg/faramir/private_key".path;
              }
            ];
          };
          git-identity = {
            workspace.personal = {
              directory = "~/Projects/Personal";
              realName = "Nicolas Villarroel M.";
              email = "nmartinezv@icloud.com";
              gpg = {
                enable = true;
                keyId = "nmartinezv@icloud.com";
              };
              ssh = {
                enableAuth = true;
                privateKeyPath = config.sops.secrets."ssh/faramir/private_key".path;
              };
            };
          };
        };
      };
  };
}
