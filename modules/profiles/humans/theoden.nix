{
  self,
  inputs,
  ...
}:
let
  inherit (self) commonModules;
in
{
  flake.profileModules.theoden = {
    system =
      { pkgs, config, ... }:
      {
        imports = [
          commonModules.sops.gpg
        ];

        sops.secrets."passwords/theoden/hashed" = {
          neededForUsers = true;
        };

        my.userProfiles.theoden = {
          username = "nicolas";
          description = "Theoden - King of Rohan";
          isSystem = false;
          isAdmin = true;
          hashedPasswordFile = config.sops.secrets."password/theoden/hashed";
        };
      };
    # darwin = {...}: {};

    user =
      { config, ... }:
      {
        imports = [
          commonModules.sops.shared-secrets
          commonModules.git-identity
        ];

        sops.secrets."ssh/theoden/private_key" = { };

        programs.git-identity = {
          enable = true;
          global = {
            enable = true;
            realName = "Nicolas Villarroel Martinez";
            email = "nicolas.villarroel@thoughtworks.com";
            gpg.enable = false;
            ssh = {
              enableAuth = true;
              privateKeyPath = config.sops.secrets."ssh/theoden/private_key".path;
            };
          };
        };
      };
  };
}
