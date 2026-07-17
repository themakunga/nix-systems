# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: nicolas-personal.nix
# Path: ./modules/profiles/nicolas-personal.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.profileModules.nicolas-personal = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
  in {
    sops.secrets = {
      "profiles/nicolas-personal/ssh/private_key" = {};
      "profiles/nicolas-personal/gpg/private_key" = {};
      "profiles/nicolas-personal/gpg/public_key" = {};
      "profiles/nicolas-personal/gpg/key_id" = {};
    };

    homebrew = mkIf isDarwin {
      casks = [
        "firefox"
        "firefox-dev"
      ];
    };

    my.userProfiles.nicolas-personal.homeManager = {
      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };

      programs = {
        sops.gpg = {
          enable = true;
          keys = [
            {
              name = "personal-key";
              publicKey = config.sops.secrets."profiles/nicolas-personal/gpg/public_key".path;
              privateKey = config.sops.secrets."profiles/nicolas-personal/gpg/private_key".path;
            }
          ];
        };
        git-identity = {
          enable = true;
          workspaces.nicolas-personal = {
            directory = "~/Projects/Personal";
            realName = "Nicolas Villarroel Martinez.";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId =
                config.sops.secrets."profiles/nicolas-personal/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = config.sops.secrets."profiles/nicolas-personal/ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
