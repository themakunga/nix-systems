{
  self,
  inputs,
  ...
}: {
  flake.profileModules.aragon = {
    # system = { ... }: { };
    # darwin = { ... }: { };
    user = {config, ...}: {
      imports = [
        self.commonModules.sops.shared-secrets
        self.commonModules.git-identity
      ];

      sops = {
        defaultSopdFile = "${inputs.secrets}/hosts/gondor.yaml";
        secrets."ssh/private_key" = {};
      };

      programs = {
        git-identity = {
          enable = true;
          global = {
            enable = true;
            realName = "Nicolas Villarroel";
            email = "nmartinezv@icloud.com";
            gpg.enable = false;
            ssh = {
              enableAuth = true;
              privateKeyPath = config.sops.sececrets."ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
