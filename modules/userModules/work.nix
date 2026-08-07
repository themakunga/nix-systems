# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Nix-Darwin
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.nicolas-work = {config, ...}: {
    imports = [
      commonModules.home-secrets
    ];

    sops.secrets."passwords/nicolas/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-work = {
      username = "nicolas";
      fullName = "Nicolas [Tu Apellido]";
      email = "nicolas@tu-empresa.com";
      description = "Work Account - To use in work pc/mac";
      isSystem = false;
      isAdmin = true;
      isNetworkManager = false;
      hashedPasswordFile = config.sops.secrets."passwords/nicolas/hashed".path;
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
