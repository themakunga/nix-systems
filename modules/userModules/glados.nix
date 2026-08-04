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
    imports = [
      commonModules.home-secrets
    ];

    users = {
      knownUsers = ["glados"];
      knownGroups = ["glados"];
      users.glados = {
        uid = 466;
        gid = 466;
      };
      groups.glados = {
        gid = 466;
      };
    };
    my.userProfiles.glados = {
      username = "glados";
      description = "Aperture Science Core AI - absolutelly not evil";
      isSystem = true;
      isAdmin = false;
      isNetworkManager = true;
      extraGroups = ["docker"];
      createHome = false;
      shell = "/usr/sbin/nologin"; # <--- Shell actualizada a nologin
    };
  };
}
