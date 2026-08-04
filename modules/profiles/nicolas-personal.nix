# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.nicolas-personal = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkIf;
    inherit (pkgs.stdenv.hostPlatform) isDarwin;
    sopsConf = {
      owner = config.my.userProfiles.personal.username or  "nicolas";
    };
  in {
    sops.secrets = {
      "profiles/personal/ssh/private_key" = sopsConf;
      "profiles/personal/gpg/private_key" = sopsConf;
      "profiles/personal/gpg/public_key" = sopsConf;
      "profiles/personal/gpg/key_id" = sopsConf;
    };

    my.apps = {
      github-cli.enable = true;
      personal = {
        enable = true;
        level = "user";
        targetUser = "nicolas";
        casks = mkIf isDarwin [
          "firefox"
          "firefox@developer-edition"
          "zen"
          "ghostty"
        ];
        packages = with pkgs; [
          lynx
          unstable.nchat
          btop
          ctop
          glab
        ];
      };
    };

    programs = {
      sops.gpg = {
        enable = true;
        keys = [
          {
            name = "personal-key";
            publicKey = config.sops.secrets."profiles/personal/gpg/public_key".path;
            privateKey = config.sops.secrets."profiles/personal/gpg/private_key".path;
          }
        ];
      };

      git-identity = {
        enable = true;
        workspaces.personal = {
          directory = "~/Projects/personal/**";
          realName = "Nicolas Villarroel Martinez.";
          email = "nmartinezv@icloud.com";
          gpg = {
            enable = true;
            keyId = config.sops.secrets."profiles/personal/gpg/key_id".path;
          };
          ssh = {
            enable = true;
            privateKey = config.sops.secrets."profiles/personal/ssh/private_key".path;
          };
        };
      };
    };
  };
}
