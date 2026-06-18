{
  self,
  inputs,
  ...
}: {
  flake.profileModules.saruman = {
    system = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        bash
      ];

      user = {
        inports = [
          self.commonModules.sops.shared-secrets
          self.commonModules.git-identity
        ];

        sops = {
          defaultSopsPath = "${inputs.secrets}/hosts/isengard.yaml";
          secrets."ssh/private_key" = {};
        };

        programs.git-identity = {
          enable = true;
          global = {
            enable = false;
          };
        };
      };
    };
  };
}
