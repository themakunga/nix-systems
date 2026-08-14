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
        inherit (lib) mkIf types mkOption;
        cfg = config.my.services.cloudflare-tunnel;
      in {
        options.my.services.cloudflare-tunnel = {
          tokenEnvFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path for the TUNNEL_TOKEN";
          };
        };

        config = mkIf config.my.services.cloudflare-tunnel.enable {
          systemd.services.cloudflare-tunnel = {
            description = "Cloudflare Tunnel (cloudflared)";
            wantedBy = ["muli-ser.target"];
            after = ["network-online.target"];

            serviceConfig = {
              EnvironmentFile =
                mkIf (cfg.tokenEnvFile != null)
                cfg.tokenEnvFile;
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
