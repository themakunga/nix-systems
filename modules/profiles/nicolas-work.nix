# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  flake.profileModules.nicolas-work = {config, ...}: {
    sops.secrets = {
      "profiles/nicolas-work/ssh/private_key" = {
        owner = config.my.userProfiles.nicolas-work.username or "nicolas";
      };
      "profiles/nicolas-work/gpg/key_id" = {
        owner = config.my.userProfiles.nicolas-work.username or "nicolas";
      };
    };

    my = {
      apps = {
        base = {
          enable = true;
          level = "user";
          targetUser = "nicolas";
          apps = [
            "typora"
            "Termius"
          ];
        };
        personal = {
          enable = true;
          level = "user";
          targetUser = "nicolas";
          apps = [
            "Whatsapp Messenger"
            "awscli2"
            "discord"
            "goodnotes"
            "nchat"
            "obsidian"
            "firefox"
            "qmk-toolbox"
            "steam"
            "via"
          ];
        };
      };

      userProfiles.nicolas-work.homeManager = {
        my.gpgProfiles = {
          enable = true;
          profiles = ["nicolas-work"];
        };

        programs.git-identity = {
          enable = true;
          workspaces.nicolas-work = {
            directory = "~/Projects";
            realName = "Nicolas Villarroel Martinez.";
            email = "nmartinezv@icloud.com";
            gpg = {
              enable = true;
              keyId = config.sops.secrets."profiles/nicolas-work/gpg/key_id".path;
            };
            ssh = {
              enableAuth = true;
              privateKey = config.sops.secrets."profiles/nicolas-work/ssh/private_key".path;
            };
          };
        };
      };
    };
  };
}
