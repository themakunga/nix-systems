# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{inputs, ...}: let
  inherit (inputs) secrets;
in {
  flake.commonModules.shared-secrets = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkOption types mkIf mapAttrsToList flatten optionalAttrs;
    cfg = config.my.sharedSecrets;
    user = config.system.primaryUser or "nicolas";

    # Función recursiva para listar todos los archivos dentro de un directorio (ruta absoluta en el store)
    # Retorna una lista de rutas relativas al directorio original.
    getFilesRecursive = dir: pathPrefix:
      if builtins.pathExists dir && builtins.readFileType dir == "directory"
      then let
        contents = builtins.readDir dir;
        processEntry = name: type:
          if type == "regular" || type == "symlink"
          then ["${pathPrefix}${name}"]
          else if type == "directory"
          then getFilesRecursive "${dir}/${name}" "${pathPrefix}${name}/"
          else [];
      in
        flatten (mapAttrsToList processEntry contents)
      else if builtins.pathExists dir && builtins.readFileType dir == "regular"
      then [""] # Es un archivo directamente
      else [];

    # Genera la lista plana de secretos expandiendo los directorios
    expandedSecrets = flatten (mapAttrsToList (
        _name: secret: let
          fullSourcePath = "${secrets.outPath}/shared-conf/${secret.source}";
          # Si la fuente es un directorio, obtnemos la lista de archivos relativos a él
          # Si es un archivo, retorna [""] para procesar el archivo mismo.
          relativeFiles = getFilesRecursive fullSourcePath "";
        in
          builtins.map (
            relFile: let
              # Si relFile está vacío, es porque el origen era un archivo directo.
              # Si no, es un archivo dentro del directorio.
              actualSource =
                if relFile == ""
                then secret.source
                else "${secret.source}/${relFile}";
              # La ruta de destino: si es directorio, agregamos el path relativo.
              actualDest =
                if relFile == ""
                then secret.path
                else "${secret.path}/${relFile}";

              # Determinamos el formato por extensión si no es binario forzado
              # sops-nix soporta yaml, json, env, ini, binary. Para simplificar, usamos la configuración del usuario.
              # Sin embargo, dotfiles mixtos suelen requerir "binary" a menos que se sepa que son yaml puros.
              actualFormat = secret.format;
            in {
              name = "shared-conf/${actualSource}";
              value =
                {
                  sopsFile = "${secrets.outPath}/shared-conf/${actualSource}";
                  path = actualDest;
                  inherit (secret) owner mode;
                  format = actualFormat;
                }
                // optionalAttrs (secret.group != null) {inherit (secret) group;};
            }
          )
          relativeFiles
      )
      cfg);
  in {
    options.my.sharedSecrets = mkOption {
      default = {};
      description = "Declarative mapping of shared-conf secrets to filesystem paths (Supports directories recursively)";
      type = types.attrsOf (
        types.submodule ({name, ...}: {
          options = {
            source = mkOption {
              type = types.str;
              default = name;
              description = "Path relative to shared-conf directory in secrets repo. Can be a file or a directory.";
            };
            path = mkOption {
              type = types.str;
              description = "Absolute path where the decrypted file(s) will be placed. If source is a directory, this acts as the base directory.";
            };
            owner = mkOption {
              type = types.str;
              default = user;
              description = "Owner of the decrypted file(s)";
            };
            group = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Group of the decrypted file(s)";
            };
            mode = mkOption {
              type = types.str;
              default = "0400";
              description = "Permissions mode";
            };
            format = mkOption {
              type = types.str;
              default = "binary";
              description = "SOPS format (binary, yaml, json, etc). Applied to all files if source is a directory.";
            };
          };
        })
      );
    };

    config = mkIf (cfg != {}) {
      sops.secrets = builtins.listToAttrs expandedSecrets;
    };
  };
}
