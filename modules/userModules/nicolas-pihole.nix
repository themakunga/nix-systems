# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: nicolas-pihole.nix
# Path: ./modules/userModules/nicolas-pihole.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.nicolas-pihole = {config, ...}: {
    sops.secrets."passwords/pihole/hashed" = {
      neededForUsers = true;
    };

    my.userProfiles.nicolas-pihole = {
      username = "pihole";
      description = "PiHole - server manager account";
      isSystem = true;
      isAdmin = true;
      isNetworkManager = true;
      hashedPasswordFile = config.sops.secrets."passwords/pihole/hashed".path;
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
