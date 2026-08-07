# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.nicolas-personal = {config, ...}: {
    imports = [
      commonModules.shared-secrets
      commonModules.shared-plain
      commonModules.secret-dotfiles
      commonModules.home-secrets
    ];

    my.secretDotfiles.enable = true;

    sops.secrets."passwords/nicolas/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-personal = {
      username = "nicolas";
      fullName = "Nicolas";
      email = "nicolas@tudominio.com";
      description = "Personal Account - Main to use";
      isSystem = false;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/nicolas/hashed".path;
      extraGroups = ["docker"];
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
