# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.zeroclaw = {config, ...}: {
    sops.secrets = {
      "profiles/zeroconf/ssh/private_key" = {
        owner = config.my.userProfiles.zeroclaw.username or "nicolas";
      };
      "profiles/zeroconf/gpg/key_id" = {
        owner = config.my.userProfiles.zeroclaw.username or "nicolas";
      };
    };

    programs = {
      git-identity = {
        enable = true;
        workspaces.zeroclaw = {
          directory = "~/Projects/ZeroClaw";
          realName = "ZeroClaw";
          email = "zeroclaw@local";
          gpg = {
            enable = true;
            keyId = config.sops.secrets."profiles/zeroconf/gpg/key_id".path;
          };
          ssh = {
            enable = true;
            privateKey = config.sops.secrets."profiles/zeroconf/ssh/private_key".path;
          };
        };
      };
    };
  };
}
