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
  flake.commonModules.shared-plain = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types mkIf mapAttrsToList flatten concatStringsSep;
    cfg = config.my.sharedPlain;
    user = config.system.primaryUser or "nicolas";

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
      then [""]
      else [];

    copyCommands = flatten (mapAttrsToList (
        _name: plainItem: let
          fullSourcePath = "${secrets.outPath}/shared-conf/${plainItem.source}";
          relativeFiles = getFilesRecursive fullSourcePath "";
        in
          builtins.map (
            relFile: let
              actualSource =
                if relFile == ""
                then "${secrets.outPath}/shared-conf/${plainItem.source}"
                else "${secrets.outPath}/shared-conf/${plainItem.source}/${relFile}";
              actualDest =
                if relFile == ""
                then plainItem.path
                else "${plainItem.path}/${relFile}";
            in ''
              mkdir -p "$(dirname "${actualDest}")"
              cp -f "${actualSource}" "${actualDest}"
              chown ${plainItem.owner}${
                if plainItem.group != null
                then ":${plainItem.group}"
                else ""
              } "${actualDest}"
              chmod ${plainItem.mode} "${actualDest}"
            ''
          )
          relativeFiles
      )
      cfg);
  in {
    options.my.sharedPlain = mkOption {
      default = {};
      description = "Declarative mapping of shared-conf files to filesystem paths";
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
              description = "Absolute path where the file(s) will be placed. If source is a directory, this acts as the base directory.";
            };
            owner = mkOption {
              type = types.str;
              default = user;
              description = "Owner of the file(s)";
            };
            group = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Group of the file(s)";
            };
            mode = mkOption {
              type = types.str;
              default = "0644";
              description = "Permissions mode";
            };
          };
        })
      );
    };

    config = mkIf (cfg != {}) {
      system.activationScripts =
        if pkgs.stdenv.isDarwin
        then {
          postActivation.text = concatStringsSep "\n" copyCommands;
        }
        else {
          copySharedPlain = {
            text = concatStringsSep "\n" copyCommands;
          };
        };
    };
  };
}
