# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: common.nix
# Path: ./modules/modules/darwin/common.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
{
  flake.darwinModules = {
    security = {
      security.pam.services = {
        sudo_local = {
          touchIdAuth = true;
        };
      };
    };
    dock = {
      config,
      lib,
      ...
    }: {
      system.defaults.dock = {
        autohide = true;
        minimize-to-application = true;
        show-recents = false;
        persistent-apps = lib.mkBefore [
          "/System/Applications/Apps.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Notes.app"
        ];
        # macOS provides the divider and the Trash after this section.
        persistent-others = [
          {folder = "${config.users.users.${config.system.primaryUser}.home}/Downloads";}
        ];
      };
    };
    finder = {
      system.defaults.finder = {
        FXPreferredViewStyle = "clmv";
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
    };
    extras = {
      nix.enable = true;

      system.defaults.NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 14;
        KeyRepeat = 1;
        _HIHideMenuBar = true;
      };
    };
  };
}
