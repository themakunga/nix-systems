# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.local-ia =
    mkAppModule "local-ia" "Enable local IA
  cli" {
      meta = {pkgs, ...}: {
        level = "system";
        packages = with pkgs; [
          ollama
          aidar-chat
        ];
      };
      sysConfig = {};
    };
}
