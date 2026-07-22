# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.nicolas-work = {config, ...}: {
    sops.secrets."passwords/nicolas/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-work = {
      username = "nicolas";
      description = "Work Account - To user in work pc/mac";
      isSystem = false;
      isAdmin = true;
      isNetworkManager = false;
      hashedPasswordFile = config.sops.secrets."passwords/nicolas/hashed".path;

      homeManager = {
        imports = [
          commonModules.home-secrets
          commonModules.git-identity
          commonModules.home-gpg-profiles
        ];

        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
        };
      };
    };
  };
}
