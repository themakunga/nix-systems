# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  self,
  inputs,
  ...
}: {
  flake.applicationModules.umami = self.lib.mkAppModule "umami" "Umami analytics on the Motherbase LAN" {
    meta = {
      level = "system";
      packages = [];
    };

    sysConfig = {
      config,
      lib,
      ...
    }: let
      project = "${self}/modules/applications/docker-host/umami";
      secretNames = ["postgres_password" "app_secret" "two_factor_key"];
    in {
      my.services.docker-host.projects.umami = project;

      sops.secrets = lib.genAttrs (map (name: "umami/${name}") secretNames) (_: {
        sopsFile = "${inputs.secrets.outPath}/common.yaml";
        owner = "root";
        mode = "0600";
        restartUnits = ["compose-umami.service"];
      });
      sops.templates."umami-env" = {
        mode = "0600";
        content = ''
          UMAMI_BIND_IP=192.168.5.153
          POSTGRES_PASSWORD=${config.sops.placeholder."umami/postgres_password"}
          APP_SECRET=${config.sops.placeholder."umami/app_secret"}
          TWO_FACTOR_ENCRYPTION_KEY=${config.sops.placeholder."umami/two_factor_key"}
        '';
      };

      # This LAN-only project uses Podman's socket and needs no ingress stack.
      systemd.services.compose-umami = {
        wants = ["network-online.target"];
        requires = lib.mkForce ["podman.socket" "sops-nix.service"];
        after = lib.mkForce ["podman.socket" "sops-nix.service" "network-online.target"];
        restartTriggers = [project];
        serviceConfig.EnvironmentFile = config.sops.templates."umami-env".path;
      };

      networking.firewall = {
        extraCommands = ''
          iptables -w -A nixos-fw -i enp2s0 -s 192.168.4.0/22 -d 192.168.5.153 -p tcp --dport 8989 -j nixos-fw-accept
        '';
        extraStopCommands = ''
          iptables -w -D nixos-fw -i enp2s0 -s 192.168.4.0/22 -d 192.168.5.153 -p tcp --dport 8989 -j nixos-fw-accept 2>/dev/null || true
        '';
      };
    };
  };
}
