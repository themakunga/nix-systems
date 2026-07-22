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
}
