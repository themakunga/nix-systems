# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.cloudflare-tunnel =
    mkAppModule "cloudflare-tunnel"
    "Clouldflare resolve dns tunnel" {
      meta = {pkgs, ...}: {
        level = "system";
        packages = [pkgs.cloudflared];
      };
      sysConfig = {
        config,
        lib,
        pkgs,
        ...
      }: let
        inherit (lib) mkIf;
      in {
        config = mkIf config.my.services.cloudflare-tunnel.enable {
          sops.secrets."applications/cloudflare_tunnel/env" = {};

          systemd.services.cloudflare-tunnel = {
            description = "Cloudflare Tunnel (cloudflared)";
            wantedBy = ["muli-ser.target"];
            after = ["network-online.target"];

            serviceConfig = {
              EnvironmentFile =
                config.sops.secrets."applications/cloudflare_tunnel/env".path;
              ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel run";
              Restart = "always";
              RestartSec = "5s";
              DynamicUser = true;
            };
          };
        };
      };
    };
}
