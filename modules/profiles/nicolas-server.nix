# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.nicolas-server = {config, ...}: {
    sops.secrets = {
      "profiles/nicolas-server/ssh/private_key" = {};
      "profiles/nicolas-server/gpg/private_key" = {};
      "profiles/nicolas-server/gpg/public_key" = {};
      "profiles/nicolas-server/gpg/key_id" = {};
    };

    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "nicolas-server-key";
            publicKey = config.sops.secrets."profiles/nicolas-server/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/nicolas-server/gpg/private_key".path;
          }
        ];
      };

      git-identity = {
        enable = true;
        workspaces.nicolas-server = {
          directory = "~/Projects";
          realName = "Nicolas Villarroel";
          email = "nmartinezv@icloud.com";
          gpg = {
            enable = true;
            keyId = config.sops.secrets."profiles/nicolas-server/gpg/key_id".path;
          };
          ssh = {
            enable = true;
            privateKey = config.sops.secrets."profiles/nicolas-server/ssh/private_key".path;
          };
        };
      };
    };
  };
}
