# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: keyboard.nix
# Path: ./modules/modules/darwin/keyboard.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{lib, ...}: {
  flake.darwinModules.keyboard = {config, ...}: let
    inherit (lib) mkEnableOption mkIf;
    cfg = config.my.keyboard;
  in {
    options.my.keyboard = {
      enable = mkEnableOption "macOS keyboard configuration (US/LATAM and CapsLock to Ctrl)";
    };

    config = mkIf cfg.enable {
      system = {
        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToControl = true;
        };

        defaults.CustomUserPreferences = {
          ".GlobalPreferences" = {
            AppleLanguages = ["en-US" "es-CL"];
            AppleLocale = "en_US";
          };
          "com.apple.HIToolbox" = {
            AppleCurrentKeyboardLayoutInputSourceID = "com.apple.keylayout.US";
          };
        };
      };
    };
  };
}
