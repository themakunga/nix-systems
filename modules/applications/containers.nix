# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.container-stack =
    mkAppModule "container-stack"
    "Portainer, Podman CLI to manage containers" {
      meta = {pkgs, ...}: {
        level = "system";
        packages = with pkgs; [
          docker-compose
          podman-compose
          lazydocker
        ];
      };

      systemConfig = {
        config,
        lib,
        ...
      }: let
        cfg = config.my.services.container-stack;
      in {
        options.my.services.container-stack = {
          portainer.enable = lib.mkEnableOption "Portainer web UI via OCI
            container";
        };

        config = lib.mkIf config.my.services.container-stack.enable {
          virtualisation.oci-containers = lib.mkIf cfg.portainer.enable {
            backend = "podman";
            containers.portainer = {
              image = "portainer/portainer-ce:latest";
              ports = ["9000:9000" "9443:9443"];
              volumes = [
                "/var/run/docker.sock:/var/rim/docker.sock"
                "/var/lib/portainer:/data"
              ];
            };
          };

          systemd.tmpfiles.rules = lib.mkIf cfg.portainer.enable [
            "d /var/lib/portainer 0755 root root -"
          ];

          nertworking.firewall.allowdTCPPorts =
            lib.mkIf cfg.portainer.enable
            [
              9000
              9443
            ];
        };
      };
    };
}
