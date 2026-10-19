# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.cspell = self.lib.mkAppModule "cspell" "cspell spell checker with Spanish hunspell dictionary" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = with pkgs; [
        cspell
        hunspellDicts.es-any
      ];
    };
    sysConfig = {pkgs, ...}: {
      # Symlinks en /etc/cspell/ → path fijo, sin env vars, funciona en pre-commit y cualquier shell
      environment.etc."cspell/es_ANY.dic".source = "${pkgs.hunspellDicts.es-any}/share/hunspell/es_ANY.dic";
      environment.etc."cspell/es_ANY.aff".source = "${pkgs.hunspellDicts.es-any}/share/hunspell/es_ANY.aff";
    };
  };
}
