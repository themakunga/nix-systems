# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# File: home-gpg-profiles.nix
# Description: Gestor automático de perfiles GPG por host.
# =========================================================
{
  flake.commonModules.home-gpg-profiles = {
    config,
    lib,
    ...
  }: let
    inherit (lib) mkEnableOption mkOption types mkIf;
    cfg = config.my.gpgProfiles;
  in {
    options.my.gpgProfiles = {
      enable = mkEnableOption "Gestor automático de llaves GPG por host";
      profiles = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };

    config = mkIf cfg.enable {
      sops.secrets = builtins.listToAttrs (
        builtins.concatMap (name: [
          {
            name = "profiles/${name}/gpg/public_key";
            value = {};
          }
          {
            name = "profiles/${name}/gpg/private_key";
            value = {};
          }
        ])
        cfg.profiles
      );

      programs.sops.gpg = {
        enable = true;
        keys =
          builtins.map (name: {
            name = "${name}-key";
            publicKey = config.sops.secrets."profiles/${name}/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/${name}/gpg/private_key".path;
          })
          cfg.profiles;
      };
    };
  };
}
