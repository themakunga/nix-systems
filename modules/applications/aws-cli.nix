# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.aws-cli = mkAppModule "aws-cli" "Enable AWS CLI" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [
        pkgs.awscli2
      ];
    };
  };
}
