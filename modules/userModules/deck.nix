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
# === DOCUMENTATION ===
# File: deck.nix
# Path: ./modules/userModules/deck.nix
# Description: Módulo de configuración para consola portátil (Deck).
# =====================
{self, ...}: let
  inherit (self) commonModules;
in {
  flake.userModules.deck = {...}: {
    imports = [
      commonModules.home-secrets
    ];

    my.userProfiles.deck = {
      username = "deck";
      fullName = "Deck Handheld";
      email = "deck@tu-dominio.com";
      description = "Handheld awsewemesd";
      isSystem = true;
      isAdmin = false;
      isNetworkManager = true;
      extraGroups = ["docker"];
      createHome = true;
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
