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
    inherit (lib) mkOption types mkIf mapAttrsToList;
    cfg = config.my.sharedSecrets;
    user = config.system.primaryUser or "nicolas";
  in {
    options.my.sharedSecrets = mkOption {
      default = {};
      description = "Declarative mapping of shared-conf secrets to filesystem paths";
      type = types.attrsOf (
        types.submodule ({name, ...}: {
          options = {
            source = mkOption {
              type = types.str;
              default = name;
              description = "Path relative to shared-conf directory in secrets repo";
            };
            path = mkOption {
              type = types.str;
              description = "Absolute path where the decrypted file will be placed";
            };
            owner = mkOption {
              type = types.str;
              default = user;
              description = "Owner of the decrypted file";
            };
            group = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Group of the decrypted file";
            };
            mode = mkOption {
              type = types.str;
              default = "0400";
              description = "Permissions mode";
            };
            format = mkOption {
              type = types.str;
              default = "binary";
              description = "SOPS format (binary, yaml, json, etc)";
            };
          };
        })
      );
    };

    config = mkIf (cfg != {}) {
      sops.secrets = builtins.listToAttrs (
        mapAttrsToList (_name: secret: {
          name = "shared-conf/${secret.source}";
          value =
            {
              sopsFile = "${secrets.outPath}/shared-conf/${secret.source}";
              inherit (secret) path owner mode format;
            }
            // lib.optionalAttrs (secret.group != null) {inherit (secret) group;};
        })
        cfg
      );
    };
  };
}
