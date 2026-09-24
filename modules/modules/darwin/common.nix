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
          "/Applications/Safari.app"
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
    mail = {
      config,
      lib,
      ...
    }: let
      user = config.system.primaryUser;
      home = config.users.users.${user}.home;
    in {
      system.activationScripts.postActivation.text = lib.mkAfter ''
        echo "=> Installing AOL new mail sound..."
        /usr/bin/install -d -o ${lib.escapeShellArg user} -m 755 ${lib.escapeShellArg "${home}/Library/Sounds"}
        /usr/bin/install -o ${lib.escapeShellArg user} -m 644 ${../../../media/sounds/aol-youve-got-mail.wav} ${lib.escapeShellArg "${home}/Library/Sounds/AOL You've Got Mail.wav"}
        if ! /usr/bin/sudo -H -u ${lib.escapeShellArg user} /usr/bin/defaults write com.apple.mail MailSound -string "AOL You've Got Mail"; then
          echo "Select AOL You've Got Mail in Mail > Settings > General > New message sound (macOS protected Mail preferences)." >&2
        fi
      '';
    };
    extras = {
      nix = {
        enable = true;
        # Gestión automática de espacio en el Nix store (macOS / nix-darwin)
        gc = {
          automatic = true;
          # launchd: domingos a las 03:00
          interval = {
            Weekday = 0;
            Hour = 3;
            Minute = 0;
          };
          options = "--delete-older-than 14d";
        };
        settings = {
          auto-optimise-store = true;
          min-free = 5368709120; # 5 GB
          max-free = 10737418240; # 10 GB
        };
      };

      system.defaults.NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 14;
        KeyRepeat = 1;
        _HIHideMenuBar = true;
      };
    };
  };
}
