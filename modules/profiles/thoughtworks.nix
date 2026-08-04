# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.thoughtworks = {
    config,
    pkgs,
    ...
  }: let
    sopsConf = {
      owner = config.my.userProfiles.nicolas-worl.username or "nicolas";
    };
  in {
    sops.secrets = {
      "profiles/thoughtworks/ssh/private_key" = sopsConf;
      "profiles/thoughtworks/gpg/private_key" = sopsConf;
      "profiles/thoughtworks/gpg/public_key" = sopsConf;
      "profiles/thoughtworks/gpg/key_id" = sopsConf;
    };

    my.apps = {
      github-cli.enable = true;
      gemini-cli.enable = true;
      thougtworks = {
        enable = true;
        level = "user";
        targetUser = "nicolas";
        packages = with pkgs; [];
        casks = [
          "google-chrome"
          "zoom"
        ];
        masApps = {};
      };
    };
    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "thoughtworks-key";
            publicKey =
              config.sops.secrets."profiles/thoughtworks/gpg/public_key".path;
            privateKey =
              config.sops.secrets."profiles/thoughtworks/gpg/private_key".path;
          }
        ];
      };
      git-identity = {
        enable = true;
        workspaces.thoughtworks = {
          directory = "~/Projects/Thoughtworks/**";
          realName = "Nicolas Villarroel";
          email = "nicolas.villarroel@thoughtworks.com";
          gpg = {
            enable = true;
            keyId = config.sops.secrets."profiles/thoughtworks/gpg/key_id".path;
          };
          ssh = {
            enable = true;
            privateKey = config.sops.secrets."profiles/thoughtworks/ssh/private_key".path;
          };
        };
      };
    };
  };
}
