# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.work = {
    config,
    pkgs,
    ...
  }: let
    sopsConf = {
      owner = config.my.userProfiles.work.username or "nicolas";
    };
  in {
    sops.secrets = {
      "profiles/work/ssh/private_key" = sopsConf;
      "profiles/work/gpg/private_key" = sopsConf;
      "profiles/work/gpg/public_key" = sopsConf;
      "profiles/work/gpg/key_id" = sopsConf;
    };

    my = {
      packages = with pkgs; [
      ];
      casks = [
        "typora"
      ];
      masApps = {
        "Termius" = 1176074088;
      };
    };

    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "work-key";
            publicKey = config.sops.secrets."profiles/work/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/work/gpg/private_key".path;
          }
        ];
      };

      # workspace declarado en el archivo de identidades del host
      git-identity.enable = true;
    };
  };
}
