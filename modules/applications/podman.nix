# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.podman =
    mkAppModule "podman" "Podman Containers
  runtime" {
      meta = { ...}: {
        level = "system";
        packages = [];
      };
      systemConfig = {
        config,
        lib,
        ...
      }: {
        config = lib.mkIf config.my.services.podman.enable {
          virtualsation = {
            container.enable = true;
            podman = {
              dockerCompat = true;
              dockerSocket.enable = true;
              defaultNetwork.settings.dns_enabled = true;
            };
          };
        };
      };
    };
}
