# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# mkBundle: resolves a spec map of { category = [ "dot.path" ... ] } into a flat
# list of NixOS/Darwin modules by looking up each path in self.<category>.
#
# extendBundle: merges a bundle spec with extra per-category lists. Categories
# absent in extensions are inherited unchanged from base.
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

  flake.lib.extendBundle = base: extensions:
    base
    // builtins.mapAttrs (
      category: extra: (base.${category} or []) ++ extra
    )
    extensions;
}
