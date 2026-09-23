# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.glow = self.lib.mkAppModule "glow" "Glow markdown renderer" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.glow];
    };
    sysConfig = {
      my.dotfiles.packages = [
        {
          name = "glow";
          isConfig = true;
        }
      ];
    };
  };
}
