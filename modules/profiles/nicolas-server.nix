# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: nicolas-server.nix
# Path: ./modules/profiles/nicolas-server.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.profileModules.nicolas-server = {config, ...}: {
    sops.secrets = {
      "profiles/nicolas-server/ssh/private_key" = {};
      "profiles/nicolas-server/gpg/private_key" = {};
      "profiles/nicolas-server/gpg/public_key" = {};
      "profiles/nicolas-server/gpg/key_id" = {};
    };

    my.userProfiles.nicolas-server.homeManager = {
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
              keyId =
                config.sops.secrets."profiles/nicolas-server/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = config.sops.secrets."profiles/nicolas-server/ssh/private_key".path;
            };
          };
        };
      };

      # home.packages = with pkgs; [ ];

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };
    };
  };
}
