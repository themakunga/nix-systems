# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.nicolas-42devs = {
    lib,
    pkgs,
    config,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
  in {
    sops.secrets = {
      "profiles/nicolas-42devs/ssh/private_key" = {};
      "profiles/nicolas-42devs/gpg/private_key" = {};
      "profiles/nicolas-42devs/gpg/public_key" = {};
      "profiles/nicolas-42devs/gpg/key_id" = {};
    };

    homebrew = mkIf isDarwin {
      casks = [
        "firefox"
        "firefox@developer-edition"
      ];
    };

    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "company-key";
            publicKey = config.sops.secrets."profiles/nicolas-42devs/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/nicolas-42devs/gpg/private_key".path;
          }
        ];
      };

      git-identity = {
        enable = true;
        workspaces.nicolas-42devs = {
          directory = "~/Projects/42Devs";
          realName = "Nicolas Villarroel Martinez.";
          email = "nicolas@42devs.cl";
          gpg = {
            enable = true;
            keyId = config.sops.secrets."profiles/nicolas-42devs/gpg/key_id".path;
          };
          ssh = {
            enable = true;
            privateKey = config.sops.secrets."profiles/nicolas-42devs/ssh/private_key".path;
          };
        };
      };
    };
  };
}
