# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{inputs, ...}: {
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
    secretsFile = "${inputs.secrets.outPath}/common.yaml";

    # AWS — solo access_key_id y secret_access_key son sensibles
    mkAwsSecret = profile: field:
      nameValuePair "aws/credentials/${profile}/${field}" {
        sopsFile = secretsFile;
      };

    awsProfilesSecrets = builtins.concatLists (
      builtins.map (p: [
        (mkAwsSecret p.name "access_key_id")
        (mkAwsSecret p.name "secret_access_key")
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
        default = [];
        description = "AWS profiles to configure. Credentials come from sops (common.yaml aws.credentials.<name>); region and output are declared here.";
        type = types.listOf (types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Profile name (matches key in aws.credentials in common.yaml)";
            };
            region = mkOption {
              type = types.str;
              default = "us-east-1";
              description = "AWS region for this profile";
            };
            output = mkOption {
              type = types.str;
              default = "json";
              description = "AWS CLI output format";
            };
          };
        });
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
