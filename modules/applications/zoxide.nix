# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.zoxide = self.lib.mkAppModule "zoxide" "Zoxide directory navigation" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.zoxide pkgs.fzf];
    };
    sysConfig = {
      my.dotfiles.packages = [
        {
          name = "zoxide";
          isConfig = true;
        }
      ];
      environment.interactiveShellInit = ''
        if [ -r "''${XDG_CONFIG_HOME:-$HOME/.config}/zoxide/init.sh" ]; then
          . "''${XDG_CONFIG_HOME:-$HOME/.config}/zoxide/init.sh"
        fi
      '';
    };
  };
}
