# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.lib.mkBundle = lib: self: specs:
    lib.flatten (
      lib.mapAttrsToList (
        category: modulePaths:
          map (
            path:
              lib.attrByPath (lib.splitString "." path)
              (throw "Error: module '${path}' dont exists in '${category}'.")
              self.${category}
          )
          modulePaths
      )
      specs
    );

  # extendBundle: extiende un bundle base añadiendo módulos por categoría.
  # Las listas se concatenan; las categorías ausentes en `extensions`
  # se heredan intactas desde `base`.
  #
  # Uso:
  #   extendBundle bundles.darwin.base {
  #     commonModules = [ "cloud-profiles" ];
  #     userModules   = [ "work" "glados" ];
  #   }
  flake.lib.extendBundle = base: extensions:
    base
    // builtins.mapAttrs (
      category: extra: (base.${category} or []) ++ extra
    )
    extensions;
}
