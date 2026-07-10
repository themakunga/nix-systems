{lib, ...}: let
  inherit (lib) mkEnableOption mkIf types mkOption mapAttrs;
in {
  flake.applicationModules.caddy = {
    main = {config, ...}: let
      cfg = config.my.caddy-main;
    in {
      options.my.caddy-main = {
        enanble = mkEnableOption "Caddt Main Server";

        email = mkOption {
          type = types.str;
          description = "Email for SSL Cert";
        };

        proxies = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = "Domain IPs/Brigeds";
          exaple = {"pihole.domain.com" = "125.0.0.1:80";};
        };
      };

      config = mkIf cfg.enable {
        networking.firewall.allowedTCPPorts = [80 443];

        service.caddy = {
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
