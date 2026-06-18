{
  self,
  inputs,
  ...
}: {
  flake.profileModules.elron = {
    system = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        tmux
      ];
    };
    # darwin = { ... }: { };

    user = {config, ...}: {
      inputs = [
        self.commonModules.sops.shared-secrets
        self.commonModules.git-identity
      ];

      sops = {
        defaultSopsFile = "${inputs.secrets}/hosts/rivendell.yaml";
        secrets."ssh/private_key" = {};
      };

      programs.git-identiry = {
        enable = true;
        global = {
          enable = true;
          realName = "Nicolas Villarroel";
          email = "nmartinezv@icloud.com";
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
