# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.thoughtworks = {config, ...}: {
    sops.secrets = {
      "profiles/thoughtworks/ssh/private_key" = {
        owner = config.my.userProfiles.nicolas-work.username or "nicolas";
      };
      "profiles/thoughtworks/gpg/key_id" = {
        owner = config.my.userProfiles.nicolas-work.username or "nicolas";
      };
    };

    my = {
      apps = {
        github-cli.enable = true;
        gemini-cli.enable = true;
        tw = {
          enable = true;
          level = "user";
          targetUser = "nicolas";
          apps = [
            "google-chrome"
            "zoom"
            "figma"
          ];
        };
      };

      userProfiles.nicolas-work.homeManager = {
        my.gpgProfiles = {
          enable = true;
          profiles = ["thoughtworks"];
        };

        programs.git-identity = {
          enable = true;
          workspaces.thoughtworks = {
            directory = "~/Projects/Thoughtworks";
            realName = "Nicolas Villarroel";
            email = "nicolas.villarroel@thoughtworks.com";
            gpg = {
              enable = true;
              keyId = config.sops.secrets."profiles/thoughtworks/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = config.sops.secrets."profiles/thoughtworks/ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
