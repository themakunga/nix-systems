{inputs, ...}: {
  flake.homeManagerModules.sops-config = {config, ...}: let
    host = config.networking.hostName or "default";
    commonSopsFile = "${inputs.secrets}/common.yaml";
    hostSopsFile = "${inputs.secrets}/hosts/${host}.yaml";
  in {
    imports = [inputs.sops-nix.homeManagerModules.sops];

    sops = {
      age = {
        sshKeyPath = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
        generateKey = false;
      };

      defaultSopsFile =
        if builtins.pathExists hostSopsFile
        then hostSopsFile
        else commonSopsFile;

      secrets = {
        "wifi/home" = {
          sopsFile = commonSopsFile;
        };
        "wifi/42devs" = {
          sopsFile = commonSopsFile;
        };

        "tailscale/auth_token" = {
          sopsFile = commonSopsFile;
        };

        github_token = {};
      };
    };
  };
}
