# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.grainger = {config, ...}: let
    sopsConf = {
      owner = config.my.userProfiles.nicolas-work.username or "nicolas";
    };
  in {
    sops.secrets = {
      "profiles/grainger/ssh/private_key" = sopsConf;
      "profiles/grainger/gpg/private_key" = sopsConf;
      "profiles/grainger/gpg/public_key" = sopsConf;
      "profiles/grainger/gpg/key_id" = sopsConf;
    };

    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "grainger-key";
            publicKey = config.sops.secrets."profiles/grainger/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/grainger/gpg/private_key".path;
          }
        ];
      };

      # workspace declarado en el archivo de identidades del host
      git-identity.enable = true;
    };
  };
}
