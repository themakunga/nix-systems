# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.codex = self.lib.mkAppModule "codex" "Codex with shared amgmt instructions and journal permissions" {
    meta = {
      pkgs,
      lib,
      ...
    }: {
      level = "system";
      packages = with pkgs; [unstable.codex stow (lib.lowPrio lua) taplo python3];
    };
    sysConfig.my.agentWiki.enable = true;
  };
}
