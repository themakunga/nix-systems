# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# mkAppModule: wraps an app into a toggleable NixOS/Darwin module under my.apps.<name>.
{
  flake.lib.mkAppModule = name: _description: {
    meta ? {},
    sysConfig ? {},
  }: {
    lib,
    config,
    ...
  } @ args: let
    childArgs = args // {pkgs = args.pkgs or config._module.args.pkgs;};
    eval = x:
      if builtins.isFunction x
      then x childArgs
      else x;
  in
    lib.mkMerge [
      {my.apps.${name} = {enable = lib.mkDefault false;} // (eval meta);}
      (lib.mkIf config.my.apps.${name}.enable (eval sysConfig))
    ];
}
