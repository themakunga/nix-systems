# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: glados.nix
# Path: ./modules/userModules/glados.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.glados = {
    my.userProfiles.glados = {
      username = "glados";
      description = "Aperture Science Core AI - absolutelly not evil";
      isSystem = true;
      isAdmin = false;
      isNetworkManager = true;
      extraGroups = ["docker"];
      createHome = true;

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
