# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{
  flake.lib.mkAppModule = name: _description: {
    meta ? {},
    sysConfig ? {},
  }: {
    lib,
    config,
    ...
  } @ args: let
    safePkgs = args.pkgs or config._module.args.pkgs;
    childArgs = args // {pkgs = safePkgs;};

    evalMeta =
      if builtins.isFunction meta
      then meta childArgs
      else meta;
    evalConf =
      if builtins.isFunction sysConfig
      then sysConfig childArgs
      else sysConfig;
  in
    lib.mkMerge [
      {
        my.apps.${name} = {enable = lib.mkDefault false;} // evalMeta;
      }
      (lib.mkIf config.my.apps.${name}.enable evalConf)
    ];
}
