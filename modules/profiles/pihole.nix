# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.pihole = {config, ...}: {
    sops.secrets = {
      "profiles/nicolas-pihole/ssh/private_key" = {};
      "profiles/nicolas-pihole/gpg/private_key" = {};
      "profiles/nicolas-pihole/gpg/public_key" = {};
      "profiles/nicolas-pihole/gpg/key_id" = {};
    };

    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "pihole-key";
            publicKey = config.sops.secrets."profiles/nicolas-pihole/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/nicolas-pihole/gpg/private_key".path;
          }
        ];
      };

      git-identity = {
        enable = true;
        workspaces.pihole = {
          directory = "~/Projects";
          realName = "Nicolas Villarroel";
          email = "nmartinezv@icloud.com";
          gpg = {
            enable = true;
            keyId = config.sops.secrets."profiles/nicolas-pihole/gpg/key_id".path;
          };
          ssh = {
            enable = true;
            privateKey = config.sops.secrets."profiles/nicolas-pihole/ssh/private_key".path;
          };
        };
      };
    };
  };
}
