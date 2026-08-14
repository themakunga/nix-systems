# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.traefik = mkAppModule "trafik" "Traefik Reverse Proxy
    containers" {
    meta = {...}: {
      level = "system";
      packages = [];
    };

    sysConfig = {
      config,
      lib,
      ...
    }: let
      cfg = config.my.services.trafik;
      inherit (lib) mkEnableOption mkIf mkOption types;
    in {
      options.my.services.trafik = {
        acmeEmail = mkOption {
          type = types.str;
          description = "Email fort certification";
        };
        useCloudflare = mkEnableOption "Use Cloudflare DNS Challenge option";
      };

      config = mkIf config.my.services.trafik.enable {
        sops.secrets."applications/traefik/cloudflare_env" =
          mkIf
          cfg.useCloudflare {};

        users.users.traefik.extraGroups = ["docker"];
        networking.firewall.allowedTCPPorts = [80 443];

        environmentFiles = mkIf cfg.useCloudflare [
          config.sops.secrets."applications/traefik/cloudflare_env".path
        ];

        staticConfigOptions = {
          api.dashboard = true;

          entryPoints = {
            web = {
              address = ":80";
              http.redirections.entryPoint = {
                to = "websecure";
                schema = "https";
              };
            };
            websecure = {
              address = ":443";
            };
          };
          providers.docker = {
            endpoint = "unix:///var/run/docker.sock";
            exposedByDefault = false;
          };
          certificatesResolver.cloudflare.acme = mkIf (cfg.acmeEmail != "") {
            email = cfg.acmeEmail;
            storage = "/var/lib/traefik/acme.json";
            dnsChallenge = {
              provider = "cloudflare";
              resolvers = ["1.1.1.1:53" "1.0.0.1:53"];
            };
          };
        };
      };
    };
  };
}
