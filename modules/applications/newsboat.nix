# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.newsboat = self.lib.mkAppModule "newsboat" "Newsboat terminal RSS/Atom reader" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.newsboat];
    };
    sysConfig = {
      my.dotfiles.packages = [
        {
          name = "newsboat";
          isConfig = true;
        }
      ];
    };
  };
}
