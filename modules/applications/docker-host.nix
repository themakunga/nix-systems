# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo: applicationModules.docker-host
# =========================================================
# Gestiona stacks Docker Compose via systemd.
#
# Stack principal (generado en Nix desde la config de túneles):
#   /opt/main → derivación Nix con compose.yaml (Portainer + cloudflared(s) + Traefik)
#
# Proyectos adicionales:
#   /opt/<name> → path estático declarado en `projects`
#   Cada servicio declara su propio subdominio via labels de Traefik.
#
# Arquitectura de redes:
#   main_ingress   (internal) — Traefik + servicios públicos + cloudflared(s)
#   cloudflared_wan (bridge)  — solo cloudflared, salida a Internet para el túnel
#   portainer_admin (bridge)  — solo Portainer (pull de imágenes)
#   opt_shared     (internal) — inter-proyectos (external en quienes participen)
#
# Traefik: Docker provider (label-based), sin routes.yaml manual.
#   Cada servicio en main_ingress se autoregistra con:
#     traefik.enable=true
#     traefik.http.routers.<name>.rule=Host(`sub.domain.com`)
#     traefik.http.services.<name>.loadbalancer.server.port=<port>
#
# Túneles Cloudflare: uno por entrada en `tunnels`; cada uno crea un
#   servicio cloudflared con su propio secreto SOPS. El secreto va en
#   ${secrets}/hosts/<host>.yaml antes de aplicar nixos-rebuild switch.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.docker-host = {lib, ...}: {
    options.my.services.docker-host = {
      tunnels = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options.tokenSecret = lib.mkOption {
            type = lib.types.str;
            description = ''
              Nombre del secreto SOPS que contiene el token del túnel.
              El valor cifrado debe existir en el sopsFile del host.
              Ejemplo: "cloudflare-tunnel-token-primary"
            '';
          };
        });
        default = {};
        example = lib.literalExpression ''
          {
            primary   = { tokenSecret = "cloudflare-tunnel-token"; };
            secondary = { tokenSecret = "cloudflare-tunnel-token-cdn"; };
          }
        '';
        description = ''
          Túneles Cloudflare a desplegar. Cada entrada crea un servicio
          cloudflared-<name> con su propio token, en main_ingress + cloudflared_wan.
        '';
      };

      projects = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = {};
        example = lib.literalExpression ''
          { demo = "''${self}/modules/applications/docker-host/demo"; }
        '';
        description = ''
          Proyectos adicionales: nombre → directorio con compose.yaml.
          Cada entrada crea /opt/<name> y un servicio compose-<name>.
          Los servicios se autoregistran en Traefik via labels Docker.
        '';
      };
    };

    imports = [
      (mkAppModule "docker-host" "Docker Compose Stacks via Nix" {
        meta = {pkgs, ...}: {
          level = "system";
          packages = with pkgs; [docker-compose lazydocker];
        };

        sysConfig = {
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.my.services.docker-host;
          compose = "${pkgs.docker-compose}/bin/docker-compose";

          # ── Generación del compose principal ──────────────────────────────
          # Un servicio cloudflared por cada túnel configurado
          cloudflaredServices = lib.mapAttrs' (name: tunnel:
            lib.nameValuePair "cloudflared-${name}" {
              image = "cloudflare/cloudflared:2025.7.0";
              restart = "unless-stopped";
              # cloudflared necesita ambas redes:
              #   cloudflared_wan → salida a Internet (conecta con Cloudflare)
              #   main_ingress    → alcanza Traefik (envía tráfico entrante)
              networks = ["cloudflared_wan" "main_ingress"];
              command = "tunnel --no-autoupdate run";
              environment = ["TUNNEL_TOKEN_FILE=/run/secrets/${tunnel.tokenSecret}"];
              volumes = ["/run/secrets/${tunnel.tokenSecret}:/run/secrets/${tunnel.tokenSecret}:ro"];
            })
          cfg.tunnels;

          mainCompose = {
            name = "main";

            networks = {
              # Traefik, cloudflared(s) y servicios públicos de proyectos
              main_ingress = {
                name = "main_ingress";
                internal = true;
              };
              # Solo para cloudflared: salida a Internet
              cloudflared_wan = {driver = "bridge";};
              # Solo para Portainer: pull de imágenes y UI
              portainer_admin = {driver = "bridge";};
              # Compartida inter-proyectos (proyectos la declaran external)
              opt_shared = {
                name = "opt_shared";
                internal = true;
              };
            };

            services =
              {
                traefik = {
                  image = "traefik:v3.3";
                  restart = "unless-stopped";
                  networks = ["main_ingress"];
                  volumes = [
                    # Socket solo lectura: Traefik lee labels, no gestiona contenedores
                    "/var/run/docker.sock:/var/run/docker.sock:ro"
                  ];
                  command = [
                    "--providers.docker=true"
                    "--providers.docker.exposedbydefault=false"
                    # Solo enruta contenedores conectados a main_ingress
                    "--providers.docker.network=main_ingress"
                    "--entrypoints.web.address=:8080"
                    "--log.level=INFO"
                  ];
                };

                portainer = {
                  image = "portainer/portainer-ce:2.21.4";
                  restart = "unless-stopped";
                  networks = ["portainer_admin"];
                  # Solo loopback: accede vía  ssh -L 9443:127.0.0.1:9443 usuario@motherbase
                  ports = ["127.0.0.1:9443:9443"];
                  volumes = [
                    "/var/run/docker.sock:/var/run/docker.sock"
                    "portainer_data:/data"
                  ];
                };
              }
              // cloudflaredServices;

            volumes = {portainer_data = null;};
          };

          # compose.yaml generado como JSON (JSON es YAML válido; docker compose lo acepta)
          mainComposeFile = pkgs.writeText "compose.yaml" (builtins.toJSON mainCompose);

          # Directorio /opt/main: derivación Nix inmutable, symlinkeada en activation
          mainOptDir = pkgs.runCommand "docker-host-main" {} ''
            mkdir -p "$out"
            cp ${mainComposeFile} "$out/compose.yaml"
          '';

          # ── Definición de servicios systemd ───────────────────────────────
          mainService = {
            "compose-main" = {
              description = "Docker Compose stack: main (Portainer, cloudflared, Traefik)";
              after = ["docker.service" "network-online.target"];
              requires = ["docker.service"];
              wantedBy = ["multi-user.target"];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                WorkingDirectory = "/opt/main";
                ExecStart = "${compose} up -d --remove-orphans";
                ExecStop = "${compose} down";
              };
            };
          };

          # Los proyectos dependen de compose-main (main crea main_ingress y opt_shared)
          mkProjectService = name: _path: {
            "compose-${name}" = {
              description = "Docker Compose stack: ${name}";
              after = ["docker.service" "compose-main.service" "network-online.target"];
              requires = ["docker.service" "compose-main.service"];
              wantedBy = ["multi-user.target"];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                WorkingDirectory = "/opt/${name}";
                ExecStart = "${compose} up -d --remove-orphans";
                ExecStop = "${compose} down";
              };
            };
          };

          # Nombres únicos de secretos (varios túneles pueden compartir token, deduplicamos)
          tunnelSecretNames = lib.unique (
            map (t: t.tokenSecret) (builtins.attrValues cfg.tunnels)
          );
        in {
          # ── Symlinks /opt/ → store Nix ───────────────────────────────────
          # ln -sfT actualiza el symlink atómicamente en cada nixos-rebuild switch.
          # Nota: tras cambiar el compose de un proyecto, reiniciar su servicio:
          #   systemctl restart compose-main  (o compose-<name>)
          system.activationScripts.docker-host-links = {
            deps = ["specialfs"];
            text = ''
              ln -sfT "${mainOptDir}" /opt/main
              ${lib.concatStringsSep "\n" (lib.mapAttrsToList (
                  name: path: "ln -sfT \"${path}\" /opt/${name}"
                )
                cfg.projects)}
            '';
          };

          # ── Servicios systemd ────────────────────────────────────────────
          systemd.services = lib.mkMerge (
            [mainService]
            ++ lib.mapAttrsToList mkProjectService cfg.projects
          );

          # ── Datos persistentes ───────────────────────────────────────────
          systemd.tmpfiles.rules = ["d /var/lib/portainer 0755 root root -"];

          # ── Secretos SOPS (uno por token único de túnel) ─────────────────
          # Agregar en ${secrets}/hosts/<host>.yaml:
          #   <tokenSecret>: ENC[AES256_GCM,...]
          # Token: Cloudflare Dashboard → Zero Trust → Tunnels → crear tunnel managed.
          sops.secrets = lib.genAttrs tunnelSecretNames (_: {
            owner = "root";
            mode = "0600";
            # sopsFile hereda defaultSopsFile del host (configurado en host-secrets.nix)
          });

          # ── Firewall ─────────────────────────────────────────────────────
          # Sin reglas adicionales:
          #   Traefik    → sin puertos de host (cloudflared llega por main_ingress)
          #   cloudflared → TCP outbound solamente
          #   Portainer  → 127.0.0.1:9443 (loopback, no atraviesa el firewall)
        };
      })
    ];
  };
}
