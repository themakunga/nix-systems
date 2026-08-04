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
_: {
  flake.commonModules.cloud-profiles = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types mkIf mkMerge listToAttrs nameValuePair;
    cfg = config.my.cloudProfiles;
    user = config.system.primaryUser or "nicolas";
    isDarwin = pkgs.stdenv.isDarwin;
    userHome =
      if isDarwin
      then "/Users/${user}"
      else "/home/${user}";

    # AWS
    mkAwsSecret = profile: field:
      nameValuePair "cloud/aws/${profile}/${field}" {
      };

    awsProfilesSecrets = builtins.concatLists (
      builtins.map (p: [
        (mkAwsSecret p "access_key_id")
        (mkAwsSecret p "secret_access_key")
        (mkAwsSecret p "region")
      ])
      cfg.aws
    );

    # GCP
    gcpProfilesSecrets = builtins.map (p:
      nameValuePair "cloud/gcp/${p}/service_account_json" {
        path = "${userHome}/.config/gcloud/legacy_credentials/${p}/adc.json";
        owner = user;
        mode = "0400";
      })
    cfg.gcp;
  in {
    options.my.cloudProfiles = {
      aws = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of AWS profiles to configure";
      };
      gcp = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of GCP profiles to configure";
      };
    };

    config = mkMerge [
      (mkIf (cfg.aws != []) {
        sops.secrets = listToAttrs awsProfilesSecrets;
      })
      (mkIf (cfg.gcp != []) {
        sops.secrets = listToAttrs gcpProfilesSecrets;
      })
    ];
  };
}
