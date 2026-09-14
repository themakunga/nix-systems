# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.yazi = self.lib.mkAppModule "yazi" "Yazi file manager" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.yazi];
    };
    sysConfig.my.dotfiles.packages = [
      {
        name = "yazi";
        isConfig = true;
      }
    ];
  };
}
