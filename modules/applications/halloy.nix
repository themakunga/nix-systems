# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.halloy = mkAppModule "halloy" "Enable Halloy IRC client" {
    meta = {
      level = "system";
      casks = ["halloy"];
    };
  };
}
