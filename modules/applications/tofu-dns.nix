# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: tofu-dns.nix
# Path: ./modules/applications/tofu-dns.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
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

      virtualisation.oci-containers = {
        backend = "podman";
        containers.tofu-dns = {
          image = "ghcr.io/opentofu/opentofu:latest";
          environmentFiles = [
            config.sops.secrets."env_files/tofu_dns".path
          ];
          environment = {
            TF_VAR_host_name = config.networking.hostName;
          };
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
          "tailscale.service"
          "podman-pihole.service"
        ];
        after = [
          "network-online.target"
          "sops-nix.service"
          "tailscale.service"
          "podman-pihole.service"
        ];
        preStart = ''
          mkdir -p /opt/tofu-dns
          ${pkgs.rsync}/bin/rsync -a --chmod=D755,F644 ${tofu-dns}/ /opt/tofu-dns/
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
