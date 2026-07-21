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
  flake.profileModules.grainger = {config, ...}: {
    sops.secrets = {
      "profiles/grainger/ssh/private_key" = {};
      "profiles/grainger/gpg/private_key" = {};
      "profiles/grainger/gpg/public_key" = {};
      "profiles/grainger/gpg/key_id" = {};
    };

    my = {
      apps = {
        grainger-tools = {
          enable = true;
          level = "user";
          targetUser = "nicolas";
          casks = ["microsoft-teams" "slack" "dbeaver-community" "rancher"];
        };
        github-cli.enable = true;
      };

      userProfiles.nicolas-work.homeManager = {
        programs = {
          sops.gpg = {
            enable = true;
            keys = [
              {
                name = "grainger-key";
                publicKey = config.sops.secrets."profiles/grainger/gpg/public_key".path;
                privateKey = config.sops.secrets."profiles/grainger/gpg/private_key".path;
              }
            ];
          };
          git-identity = {
            enable = true;
            workspaces.grainger = {
              directory = "~/Projects/Grainger";
              realName = "Villarroel, Nicolas";
              email = "nicolas.villarroel1@grainger.com";
              gpg = {
                enable = true;
                keyId = config.sops.secrets."profiles/grainger/gpg/key_id".path;
              };
              ssh = {
                enableAuth = true;
                privateKey = config.sops.secrets."profiles/grainger/ssh/private_key".path;
              };
            };
          };
        };
        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
        };
      };
    };
  };
}
