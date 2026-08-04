# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.latam = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    sopsConf = {
      owner = config.my.userProfiles.nicolas-work.username or "nicolas";
    };
  in {
    sops.secrets = {
      "profiles/latam/ssh/private_key" = sopsConf;
      "profiles/latam/gpg/private_key" = sopsConf;
      "profiles/latam/gpg/public_key" = sopsConf;
      "profiles/latam/gpg/key_id" = sopsConf;
    };

    my.apps = {
      github-cli.enable = true;
      gitlab-cli.enable = true;
      latam-tools = {
        enable = true;
        level = "user";
        targetUser = "nicolas";
        casks = mkIf isDarwin [
          "dbeaver-community"
          "bruno"
        ];
      };
    };

    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "latam-key";
            publicKey = config.sops.secrets."profiles/latam/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/latam/gpg/private_key".path;
          }
        ];
      };

      git-identity = {
        enable = true;
        workspaces.latam = {
          directory = "~/Projects/latam/**";
          realName = "Villarroel, Nicolas";
          email = "nicolasvillarroel.thoughtworks@latam.com";
          gpg = {
            enable = true;
            keyId = config.sops.secrets."profiles/latam/gpg/key_id".path;
          };
          ssh = {
            enable = true;
            privateKey = config.sops.secrets."profiles/latam/ssh/private_key".path;
          };
        };
      };
    };
  };
}
