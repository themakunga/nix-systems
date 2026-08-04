# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.nicolas-bbook = {
    lib,
    pkgs,
    config,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
  in {
    sops.secrets = {
      "profiles/nicolas-bbook/ssh/private_key" = {};
      "profiles/nicolas-bbook/gpg/private_key" = {};
      "profiles/nicolas-bbook/gpg/public_key" = {};
      "profiles/nicolas-bbook/gpg/key_id" = {};
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
            name = "bbook-key";
            publicKey = config.sops.secrets."profiles/nicolas-bbook/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/nicolas-bbook/gpg/private_key".path;
          }
        ];
      };

      git-identity = {
        enable = true;
        workspaces.nicolas-bbook = {
          directory = "~/Projects/Bbook";
          realName = "Nicolas Villarroel Martinez.";
          email = "nmartinez@bbook.cl";
          gpg = {
            enable = true;
            keyId = config.sops.secrets."profiles/nicolas-bbook/gpg/key_id".path;
          };
          ssh = {
            enable = true;
            privateKey = config.sops.secrets."profiles/nicolas-bbook/ssh/private_key".path;
          };
        };
      };
    };
  };
}
