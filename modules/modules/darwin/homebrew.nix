# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: homebrew.nix
# Path: ./modules/modules/darwin/homebrew.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.darwinModules.homebrew = {
    config,
    inputs,
    ...
  }: let
    inherit (inputs) homebrew-core homebrew-cask homebrew-bundle;
  in {
    nix-homebrew = {
      enable = true;
      autoMigrate = true;
      mutableTaps = false;
      user = config.system.primaryUser;
      taps = {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
        "homebrew/homebrew-bundle" = homebrew-bundle;
      };
    };

    homebrew = {
      enable = true;
      global.autoUpdate = true;
      taps = builtins.attrNames config.nix-homebrew.taps;

      onActivation = {
        autoUpdate = true;
        upgrade = true;
        cleanup = "zap";
      };

      brews = [
        "mas" # Habilita la Mac App Store
      ];
      casks = [];
      masApps = {};
    };
  };

  flake.darwinModules.homebrewPackages = {
    brews ? [],
    casks ? [],
    masApps ? {},
  }: {
    homebrew = {
      inherit brews casks masApps;
    };
  };
}
