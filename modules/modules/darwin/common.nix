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
      system.defaults.dock = {
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
