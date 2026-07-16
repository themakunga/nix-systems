# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: steamdeck.nix
# Path: ./modules/profiles/steamdeck.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.profileModules.steamdeck = {config, ...}: {
    sops.secrets = {
      "profiles/steamdeck/ssh/private_key" = {};
      "profiles/steamdeck/gpg/private_key" = {};
      "profiles/steamdeck/gpg/public_key" = {};
      "profiles/steamdeck/gpg/key_id" = {};
    };

    my.userProfiles.deck.homeManager = {
      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "steamdeck-key";
              publicKey = config.sops.secrets."profiles/steamdeck/gpg/public_key".path;
              privateKey = config.sops.secrets."profiles/steamdeck/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.steamdeck = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId = config.sops.secrets."profiles/steamdeck/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = config.sops.secrets."profiles/steamdeck/ssh/private_key".path;
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
