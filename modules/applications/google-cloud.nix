# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.google-cloud = {
    gcloud = mkAppModule "gcloud" "Enable Google Cloud SDK" {
      meta = {pkgs, ...}: {
        level = "system";
        packages = [pkgs.google-cloud-sdk];
      };
    };
  };
}
