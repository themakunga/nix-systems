# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# =========================================================
{
  flake.profileModules.nicolas-work = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets = {
      "profiles/nicolas-work/ssh/private_key" = {owner = config.my.userProfiles.nicolas-work.username or "nicolas";};
      "profiles/nicolas-work/gpg/key_id" = {owner = config.my.userProfiles.nicolas-work.username or "nicolas";};
    };

    my = {
      apps = {
        base = {
          enable = true;
          level = "user";
          targetUser = "nicolas";
          casks = ["typora"];
          masApps = {"Termius" = 1176074088;};
        };
        personal = {
          enable = true;
          level = "user";
          targetUser = "nicolas";
          packages = with pkgs; [awscli2 nchat];
          casks = ["discord" "firefox" "obsidian" "qmk-toolbox" "steam" "via"];
          masApps = {
            "Whatsapp Messenger" = 310633997;
            "goodnotes" = 1444383602;
          };
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
