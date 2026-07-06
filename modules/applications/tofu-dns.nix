{inputs, ...}: let
  inherit (inputs) tofu-dns;
in {
  flake.applicationModules.tofu-dns = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf mkForce;
    cfg = config.my.tofu-dns;
  in {
    options.my.tofu-dns = {
      enable = mkEnableOption "OpenTofu DNS deployment";
    };

    config = mkIf cfg.enable {
      sops.secrets."env_files/tofu_dns" = {};

      virtualization.oci-containers = {
        backend = "podman";
        containers.tofu-dns = {
          image = "ghcr.io/opentofu/opentofu:latest";
          environmentFiles = [
            config.sops.secrets."env_files/tofu_dns".path
          ];
          volumes = [
            "/opt/tofu-dns:/workspace"
          ];
          entrypoint = "/bin/sh";
          cmd = [
            "-c"
            "tofu init && tofu apply -auto-approve"
          ];
        };
      };

      systemd.services."podman-tofu-dns" = {
        wants = [
          "network-online.target"
          "sops-nix.service"
        ];
        after = [
          "network-online.target"
          "sops-nix-service"
        ];
        preStart = ''
          mkdir -p /opt/tofu-dns
          ${pkgs.rsync}/bin/rsync -a --chmod=D755,F644 ${inputs.tofu-dns}/ /opt/tofu-dns/
        '';

        serviceConfig = {
          Restart = mkForce "no";
          Type = mkForce "oneshot";
          RemainAfterExit = mkForce true;
        };
      };
    };
  };
}
