{
  self,
  inputs,
  ...
}: {
  flake.profileModules.celebimbor = {
    system = {pkgs, ...}: {
      environment.systenmPackages = with pkgs; [
        bash
      ];
    };
    user = {config, ...}: {
      inports = [
        self.commonModules.sops.shared-secrets
        self.commonModules.git-identity
      ];

      sops = {
        defaultSopsFile = "${inputs.secrets}/hosts/eregoin.yaml";
        secrets."ssh/private_key" = {};
      };

      programs.git-identity = {
        enable = true;
        global = {
          enable = true;
          realName = "Celebimbor";
          email = "celebimbor@eregoin.local";
          gpg.enable = false;
          ssh = {
            enable = true;
            privateKeyPath = config.sops.secrets."ssh/private_key".path;
          };
        };
      };
    };
  };
}
