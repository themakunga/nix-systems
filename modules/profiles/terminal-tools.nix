# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.terminal-tools = {
    my = {
      dotfiles.enable = true;
      apps = {
        yazi.enable = true;
        zoxide.enable = true;
      };
    };
  };
}
