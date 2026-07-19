# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
name: description: appConfig: {
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.${name};
in {
  options.my.${name}.enable = mkEnableOption description;

  config = mkIf cfg.enable (
    if builtins.isFunction appConfig
    then appConfig {inherit pkgs lib config;}
    else appConfig
  );
}
