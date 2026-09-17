# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.terminal-tools = {pkgs, ...}: {
    my = {
      dotfiles.enable = true;
      packages = [pkgs.unstable.tuxedo];
      apps = {
        bat.enable = true;
        yazi.enable = true;
        zoxide.enable = true;
      };
    };
  };
}
