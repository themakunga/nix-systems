{ inputs, ... }:
{
  flake = {
    darwinModules = {
      nix-homebrew-config =
        {
          nix-homebrew,
          brew-core,
          brew-cask,
          ...
        }:
        {
          nix-homebrew = {
            enable = true;
            autoMigrate = true;
            mutableTaps = false;
            taps = {
              "homebrew/homebrew-core" = brew-core;
              "homebrew/homebrew-cask" = brew-cask;
            };
          };
        };
      homebrew-config =
        { pkgs, config, ... }:
        {
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
              "mas"
            ];
            casks = [

            ];
            masApps = {
              "Xcode" = 497799835;
            };

          };
        };
      gui-common-browsers = {
        homebrew.casks = [
          "google-chome"
          "firefox"
          "firefox-dev"
        ];
      };
      gui-common-documents = {
        homebrew.casks = [
          "typora"
        ];
        homebrew.brews = [
          "pandoc"
        ];
      };
      gui-common-socials = {
        homebrew.casks = [
          "slack"
          "discord"
          "mattermost"
        ];
      };
      common-config =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          lib.generators.toPlist.escape = true;
          security = {
            pam = {
              service = {
                sudo_local = {
                  touchIdAuth = true;
                };
              };
            };
          };
          system = {
            stateVersion = 6;
            defaults = {
              dock = {
                autohide = true;
                minimize-to-application = true;
                show-recents = false;
                persistent-apps = [
                  "/System/Applications/Apps.app"
                  "/System/Applications/Mail.app"
                  "/System/Applications/Calendar.app"
                  "/Applications/Safari.app"
                  "/System/Applications/Notes.app"
                  "/System/Applications/Phone.app"
                  {
                    spacer.small = true;
                  }
                ];
              };
              finder = {
                FXPreferredViewStyle = "clmv";
                AppleShowAllExtensions = true;
                _FXShowPosixPathInTitle = true;
              };
              NSGlobalDomain = {
                AppleShowAllExtensions = true;
                InitialKeyRepeat = 14;
                KeyRepeat = 1;
                _HIHideMenuBar = true;
              };
            };
            keyboard = {
              enableKeyMapping = true;
              remapCapsLockToControl = true;
            };
          };
        };
    };
  };
}
