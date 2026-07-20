# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.lib.mkAppModule = name: _description: appConfig: {
    lib,
    config,
    ...
  } @ args: let
    inherit (lib) mkIf;
    cfg = config.my.apps.${name};
  in {
    config = mkIf cfg.enable (
      if builtins.isFunction appConfig
      then appConfig args
      else appConfig
    );
  };
}
