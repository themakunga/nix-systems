# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: caddy.nix
# Path: ./modules/applications/caddy.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{lib, ...}: let
  inherit (lib) mkEnableOption mkIf types mkOption mapAttrs;
in {
  flake.applicationModules.caddy = {
    main = {config, ...}: let
      cfg = config.my.caddy-main;
    in {
      options.my.caddy-main = {
        enable = mkEnableOption "Caddt Main Server";

        email = mkOption {
          type = types.str;
          description = "Email for SSL Cert";
        };

        proxies = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = "Domain IPs/Brigeds";
          example = {"pihole.domain.com" = "125.0.0.1:80";};
        };
      };

      config = mkIf cfg.enable {
        networking.firewall.allowedTCPPorts = [80 443];

        services.caddy = {
          enable = true;

          inherit (cfg) email;

          virtualHosts =
            mapAttrs (_domain: upstream: {
              extraConfig = ''
                reverse_proxy = ${upstream}
              '';
            })
            cfg.proxies;
        };
      };
    };
    node = {config, ...}: let
      cfg = config.my.caddy-host;
    in {
      options.my.caddy-node = {
        enable = mkEnableOption "Caddy node";
      };

      config = mkIf cfg.enable {
        services.caddy.enable = true;
      };
    };
  };
}
