# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: kvm.nix
# Path: ./modules/applications/kvm.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.applicationModules.kvm = {
    lib,
    config,
    pkgs,
    ...
  }: let
    inherit (lib) mkIf mkEnableOption types mkOption;
    cfg = config.my.kvm;
  in {
    options.my.kvm = {
      enable = mkEnableOption "PiKVM uStreamer service";

      device = mkOption {
        type = types.str;
        default = "/dev/video0";
      };

      port = mkOption {
        type = types.port;
        default = 8080;
      };

      resolution = mkOption {
        type = types.str;
        default = "1920x1080";
      };
    };

    config = mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        ustreamer
        v4l-utils
      ];

      systemd.services.ustreamer = {
        description = "uStreamer Video Capture";
        wantedBy = ["multi-user.target"]; # Corregido
        after = ["network.target"];
        serviceConfig = {
          DynamicUser = true;
          SupplementaryGroups = ["video"];
          ExecStart = "${pkgs.ustreamer}/bin/ustreamer --device=${cfg.device} --host=0.0.0.0 --port=${toString cfg.port} --resolution=${cfg.resolution} --format=mjpeg";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      networking.firewall.allowedTCPPorts = [cfg.port];
    };
  };
}
