{inputs, ...}: {
  flake.commonModules.host-secrets = {
    lib,
    config,
    ...
  }: let
    inherit (lib) mkOption types mkDefault;
    cfg = config.my.hostSecrets;
  in {
    options.my.hostSecrets = {
      file = mkOption {
        type = types.str;
        default = "${inputs.secrets}/common.yaml";
        description = "Secrets path";
      };
    };

    config = {
      sops = {
        defaultSopsFile = mkDefault cfg.file;

        validateSopsFiles = false;

        age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      };
    };
  };
}
