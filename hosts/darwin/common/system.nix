{ pkgs, ... }:
{
  lib = {
    generators = {
      toPlist = {
        escape = true;
      };
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";

  security = {
    pam = {
      services = {
        sudo_local = {
          touchIdAuth = true;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    iterm2
  ];

  programs = {
    zsh = {
      enable = true;
    };
  };

  system = {
    stateVersion = 6;
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
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };

}
