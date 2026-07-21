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
    safePkgs = args.pkgs or config._module.args.pkgs;

    childArgs = args // {pkgs = safePkgs;};
  in
    lib.mkMerge [
      {
        my.apps.${name}.enable = lib.mkDefault false;
      }

      (lib.mkIf config.my.apps.${name}.enable (
        if builtins.isFunction appConfig
        then appConfig childArgs
        else appConfig
      ))
    ];
}
