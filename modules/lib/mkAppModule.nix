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

    evaluated =
      if builtins.isFunction appConfig
      then appConfig childArgs
      else appConfig;

    hasMyApp = evaluated ? my && evaluated.my ? apps && evaluated.my.apps ? ${name};
    appMeta =
      if hasMyApp
      then evaluated.my.apps.${name}
      else {};

    payload =
      if hasMyApp
      then
        builtins.removeAttrs evaluated ["my"]
        // {
          my =
            builtins.removeAttrs evaluated.my ["apps"]
            // {
              apps = builtins.removeAttrs evaluated.my.apps [name];
            };
        }
      else evaluated;
  in
    lib.mkMerge [
      {
        my.apps.${name} = appMeta // {enable = lib.mkDefault false;};
      }

      (lib.mkIf config.my.apps.${name}.enable payload)
    ];
}
