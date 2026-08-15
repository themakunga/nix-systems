# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo: applicationModules.cloudflare-tunnel
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
  inherit (self.inputs) secrets;
in {
  flake.applicationModules.cloudflare-tunnel = mkAppModule "cloudflare-tunnel" "Cloudflare Tunnel" {
    meta = _: {
      level = "system";
      packages = [];
    };

    sysConfig = {
      config,
      pkgs,
      ...
    }: {
      sops.secrets.cloudflare_tunnel_env = {
        sopsFile = "${secrets}/common.yaml";
      };

      environment.systemPackages = [pkgs.cloudflared];

      systemd.services.cloudflare-tunnel = {
        description = "Cloudflare Tunnel (cloudflared)";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target"]; # <--- AÑADE ESTO AQUÍ
        after = ["network-online.target"];

        serviceConfig = {
          EnvironmentFile = config.sops.secrets.cloudflare_tunnel_env.path or "";
          ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel run";
          Restart = "always";
          RestartSec = "5s";
          DynamicUser = true;
        };
      };
    };
  };
}
