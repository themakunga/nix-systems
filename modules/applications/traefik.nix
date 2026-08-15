# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo: applicationModules.traefik
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
  inherit (self.inputs) secrets;
in {
  flake.applicationModules.traefik = {lib, ...}: {
    # Extraemos las opciones fuera del mkAppModule para que Nix las lea siempre
    options.my.services.traefik = {
      acmeEmail = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Email for Let's Encrypt certification";
      };
      useCloudflare = lib.mkEnableOption "Usar Cloudflare DNS Challenge";
    };

    imports = [
      (mkAppModule "traefik" "Traefik Reverse Proxy" {
        meta = _: {
          level = "system";
          packages = [];
        };

        sysConfig = {
          config,
          lib,
          ...
        }: let
          cfg = config.my.services.traefik;
        in {
          sops.secrets.traefik_cloudflare_env = lib.mkIf cfg.useCloudflare {
            sopsFile = "${secrets}/common.yaml";
          };

          users.users.traefik.extraGroups = ["docker"];
          networking.firewall.allowedTCPPorts = [80 443];

          services.traefik = {
            enable = true;

            environmentFiles = lib.mkIf cfg.useCloudflare [
              (config.sops.secrets.traefik_cloudflare_env.path or "")
            ];

            staticConfigOptions = {
              api.dashboard = true;
              entryPoints = {
                web = {
                  address = ":80";
                  http.redirections.entryPoint = {
                    to = "websecure";
                    scheme = "https";
                  };
                };
                websecure = {address = ":443";};
              };
              providers.docker = {
                endpoint = "unix:///var/run/docker.sock";
                exposedByDefault = false;
              };
              certificatesResolvers.cloudflare.acme = lib.mkIf (cfg.acmeEmail != "") {
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
      })
    ];
  };
}
