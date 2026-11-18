# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: {
  flake.applicationModules.matcha = self.lib.mkAppModule "matcha" "Enable Matcha terminal email client" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.unstable.matcha];
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
      my.dotfiles.packages = [
        {
          name = "matcha";
          isConfig = true;
        }
      ];
      my.sharedSecrets.matcha = {
        source = "matcha";
        path = "${userHome}/.config/matcha";
        mode = "0600";
      };
    };
  };
}
