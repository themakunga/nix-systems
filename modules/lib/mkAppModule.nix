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
  } @ args:
    lib.mkMerge [
      {
        # 1. Aseguramos que la app SIEMPRE exista en el diccionario.
        # Al darle un valor por defecto (false), Nix ya no necesita evaluar todo
        # el bloque condicional para saber si existe o no, rompiendo la recursión infinita.
        my.apps.${name}.enable = lib.mkDefault false;
      }

      # 2. Inyectamos la configuración de la app SOLO si el host la encendió (enable = true).
      (lib.mkIf config.my.apps.${name}.enable (
        if builtins.isFunction appConfig
        then appConfig args
        else appConfig
      ))
    ];
}
