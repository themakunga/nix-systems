# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self.lib) mkAppModule;
in {
  flake.applicationModules.cliamp = mkAppModule "cliamp" "Enable cliamp terminal music player (Spotify, YT Music, podcasts, radio)" {
    meta = {pkgs, ...}: {
      level = "system";
      packages = [pkgs.unstable.cliamp];
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
      my.sharedPlain.cliamp = {
        source = "cliamp";
        path = "${userHome}/.config/cliamp";
        mode = "0600";
      };
    };
  };
}
