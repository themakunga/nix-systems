# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: nicolas-server.nix
# Path: ./modules/userModules/nicolas-server.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.nicolas-server = {config, ...}: {
    sops.secrets."passwords/nicolas/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-server = {
      username = "nicolas";
      description = "Nicolas server - server manager account";
      isSystem = true;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/nicolas/hashed".path;
      extraGroups = ["docker"];
      homeManager = {
        imports = [
          commonModules.home-secrets
          commonModules.git-identity
        ];

        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
        };
      };
    };
  };
}
