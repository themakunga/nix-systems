# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.bat = self.lib.mkAppModule "bat" "Bat syntax-highlighted cat" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.bat];
    };
    sysConfig = {
      my.dotfiles.packages = [
        {
          name = "bat";
          isConfig = true;
        }
      ];
      environment.interactiveShellInit = ''
        if [ -r "''${XDG_CONFIG_HOME:-$HOME/.config}/bat/init.sh" ]; then
          . "''${XDG_CONFIG_HOME:-$HOME/.config}/bat/init.sh"
        fi
      '';
    };
  };
}
