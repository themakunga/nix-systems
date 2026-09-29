# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.halloy = mkAppModule "halloy" "Enable Halloy IRC client" {
    meta = {
      level = "system";
      casks = ["halloy"];
    };
    sysConfig = {
      config,
      pkgs,
      ...
    }: let
      user = config.system.primaryUser or "nicolas";
      userHome =
        if pkgs.stdenv.isDarwin
        then "/Users/${user}"
        else "/home/${user}";
    in {
      my.sharedPlain.halloy = {
        source = "halloy";
        path = "${userHome}/.config/halloy";
        mode = "0600";
      };
    };
  };
}
