# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.mediaserver = {config, ...}: {
    sops.secrets = {
      "profiles/mediaserver/ssh/private_key" = {};
      "profiles/mediaserver/gpg/private_key" = {};
      "profiles/mediaserver/gpg/public_key" = {};
      "profiles/mediaserver/gpg/key_id" = {};
    };

    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "mediaserver-key";
            publicKey = config.sops.secrets."profiles/mediaserver/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/mediaserver/gpg/private_key".path;
          }
        ];
      };

      git-identity = {
        enable = true;
        workspaces.mediaserver = {
          directory = "~/Projects/**";
          realName = "Nicolas Villarroel";
          email = "nmartinezv@icloud.com";
          gpg = {
            enable = true;
            keyId = config.sops.secrets."profiles/mediaserver/gpg/key_id".path;
          };
          ssh = {
            enable = true;
            privateKey = config.sops.secrets."profiles/mediaserver/ssh/private_key".path;
          };
        };
      };
    };
  };
}
