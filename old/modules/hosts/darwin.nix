{
  config,
  lib,
  pkgs,
}:
with lib;
{
  imports = [
    ./common.nix
  ];

  system = {
    stateVersion = 6;
    defaults = {
      dock = {
        enable = true;
        autohide = true;
        minimize-to-application = true;
        show-recents = false;
        persistent-apps = [
          "/System/Applications/Apps.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Safari.app"
          "/System/Applications/Notes.app"
        ];
        persistent-others = [
          {
            title-type = "spacer-title";
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

  lib = {
    generators = {
      toPlist = {
        escape = true;
      };
    };
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config = {
      allowUnfree = true;
    };
  };

  security = {
    pam = {
      services = {
        sudo_local = {
          touchIdAuth = true;
        };
      };
    };
  };

  envirionment.systemPackages = with pkgs; [
    iterm2
    oh-my-posh
  ];

  programs = {
    zsh = {
      enable = true;
    };
  };

  homebrew = {
    enable = true;
    global = {
      autoUpdate = true;
    };
    taps = builtins.attrNames config.nix-homebrew.taps;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brew = [
      "mas"
    ];
    cask = [

    ];
    masApps = {
      "Xcode" = 497799835;
    };
  };
}
