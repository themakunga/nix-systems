{
  self,
  lib,
  ...
}: {
  flake = {
    commonModules.grainger = {pkgs, ...}: let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
    in {
      users.users.nicolas = {
        description = "Nicolas Villarroel.";
        extraGrourps = lib.mkIf (!isDarwin) [
          "wheel"
          "networkmanager"
          "docker"
        ];
        isNormalUser = lib.mkIf (!isDarwin) true;
      };
    };
    darwinModules.grainger = {
      imports = [
        self.darwinModules.homebrew-config
      ];

      homebrew.casks = [
        "microsoft-teams"
      ];
    };
    homeManagerModules.grainger = {config, ...}: {
      imports = [
        self.homeManagerModules.default
      ];

      home = {
        username = "nicolas";
      };
      programs.git.include = {
        condition = "gitdir:~/Projects/Grainger/";
        contents = {
          user.email = "nicolas.villarroel@grainger.com";
          core.sshCommand = "ssh -i ${config.sops.secrets."grainger_ssh_key".path} -o IdentitiesOnly=yes";
        };
      };
    };
  };
}
