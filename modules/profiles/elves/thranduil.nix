{
  self,
  inputs,
  ...
}: {
  flake.profileModules.thranduil = {
    # system  = {...}: {};
    user = {config, ...}: {
      inports = [
        self.commonModules.sops.shared-secrts
        self.commonModules.git-identity
      ];

      sops = {
        defaultSopsFile = "${inputs.secrets}/hosts/mirkwood.yaml";
        secrets."ssh/private_key" = {};
      };

      programs.git-identity = {
        enable = true;
        global = {
          enable = true;
          realName = "Nicolas Martinez V";
          email = "nmartinezv@icloud.com";
          gpg.enable = false;
          ssh = {
            enable = true;
            privarteKeyPath = config.sops.secrets."ssh/private_key".path;
          };
        };
      };
    };
  };
}
