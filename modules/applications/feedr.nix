# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.feedr = self.lib.mkAppModule "feedr" "Feedr terminal RSS/Atom reader" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.feedr];
    };
    sysConfig = {
      my.dotfiles.packages = [
        {
          name = "feedr";
          isConfig = true;
        }
      ];
    };
  };
}
