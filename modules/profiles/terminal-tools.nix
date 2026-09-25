# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.terminal-tools = {pkgs, ...}: {
    my = {
      dotfiles.enable = true;
      dotfiles.packages = [
        {
          name = "codex";
          output-name = ".codex";
        }
        {
          name = "claude";
          output-name = ".claude";
        }
        {
          name = "scripts";
          output-name = "scripts"; # ~/scripts/ — jira-start y otros scripts ejecutables
        }
      ];
      packages = [pkgs.unstable.tuxedo];
      apps = {
        bat.enable = true;
        glow.enable = true;
        yazi.enable = true;
        zoxide.enable = true;
      };
    };
  };
}
