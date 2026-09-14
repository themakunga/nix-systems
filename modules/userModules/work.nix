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
  flake.userModules.work = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      commonModules.home-secrets
    ];

    sops.secrets."passwords/nicolas/hashed" = {
      neededForUsers = pkgs.stdenv.isLinux;
    };

    my.userProfiles.work = {
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
