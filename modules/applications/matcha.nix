# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.matcha = self.lib.mkAppModule "matcha" "Enable Matcha terminal email client" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.unstable.matcha];
    };
    sysConfig = {
      my.dotfiles.packages = [
        {
          name = "matcha";
          isConfig = true;
        }
      ];
    };
  };
}
