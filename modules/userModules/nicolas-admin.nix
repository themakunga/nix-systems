# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: nicolas-admin.nix
# Path: ./modules/userModules/nicolas-admin.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.nicolas-admin = {config, ...}: {
    sops.secrets."passwords/nicolas-admin/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-admin = {
      username = "nicolas";
      description = "Nicolas - admin manager account";
      isSystem = true;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/nicolas-admin/hashed".path;
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
