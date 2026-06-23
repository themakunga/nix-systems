{
  self,
  ...
}:
let
  inherit (self) commonModules;
in
{
  flake.profileModules.aragon = {
    system =
      { pkgs, config, ... }:
      {
        imports = [
          commonModules.sops.gpg
        ];

        sops.secrets."passwords/aracon/hashed" = {
          neededForUsers = true;
        };

        my.userProfiles.aragon = {
          username = "nicolas";
          description = "Aragon - King of Gondor";
          isAdmin = true;
          isSystem = false;
          createHome = true;
          extraGroups = [ "docker" ];
          hashedPasswordFile = config.sops.secrets."passwords/aragon/hashed".path;
        };
      };
    darwin = { ... }: { };
    user =
      { config, ... }:
      {
        imports = [
          commonModules.sops.shared-secrets
          commonModules.git-identity
        ];

        sops.secrets."ssh/aragon/private_key" = { };

        programs.git-identiry = {
          enable = true;
          global = {
            enable = true;
            realName = "Nicolas Villarroel M";
            email = "nmartinezv@icloud.com";
            ssh = {
              enableAuth = true;
              privateKeyPath = config.sops.secrets."ssh/aragon/private_key".path;
            };
          };
        };
      };
  };
}
