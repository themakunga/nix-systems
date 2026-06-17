{
  self,
  inputs,
  ...
}: {
  flake.profileModules.theoden = {
    # system = {...}: {};
    # darwin = {...}: {};

    user = {config, ...}: {
      imports = [
        self.commonModules.sops.shared-secrets
        self.commonModules.git-identity
      ];

      sops = {
        defaultSopsFile = "${inputs.secrets}/hosts/rohan.yaml";

        secrets."ssh/private_key" = {};
      };

      programs.git-identity = {
        enable = true;
        global = {
          enable = true;
          realName = "Nicolas";
          email = "nicolas@tucorreo.com"; # Cambiar por tu correo principal
          gpg.enable = false;
          ssh = {
            enableAuth = true;
            privateKeyPath = config.sops.secrets."ssh/private_key".path;
          };
        };
      };
    };
  };
}
