{ inputs, ... }:
{
  flake = {
    darwinModules = {
      homebrew =
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
      configuration =
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
