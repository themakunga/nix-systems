# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: pihole.nix
# Path: ./modules/applications/pihole.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.applicationModules.pihole = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.pihole;
  in {
    options.my.pihole = {
      enable = mkEnableOption "Main config pihole";
    };

    config = mkIf cfg.enable {
      sops.secrets."passwords/pihole/hashed" = {};

      virtualisation.oci-containers = {
        backend = "podman";
        containers.pihole = {
          image = "pihole/pihole:latest";
          ports = [
            "53:53/tcp"
            "53:53/udp"
            "80:80/tcp"
          ];
          environment = {
            TZ = "America/Santiago";
            WEBPASSWORD_FILE = config.sops.secrets."passwords/pihole/hashed".path;
            PIHOLE_DNS_ = "1.1.1.1;1.0.0.1";
          };
          volumes = [
            "/var/lib/pihole/etc-pihole:/etc/pihole"
            "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
            "${config.sops.secrets."passwords/pihole/hashed".path}:${config.sops.secrets."passwords/pihole/hashed".path}:ro"
          ];
          extraOptions = [
            "--cap-add=NET_ADMIN"
          ];
        };
      };

      networking.firewall = {
        allowedTCPPorts = [53 80];
        allowedUDPPorts = [53];
      };
    };
  };
}
