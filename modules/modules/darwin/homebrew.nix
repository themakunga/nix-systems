{lib, ...}: {
  flake.darwinModules.homebrew = {
    config,
    homebrew-core,
    homebrew-cask,
    ...
  }: {
    nix-homebrew = {
      enable = true;
      autoMigrate = true;
      mutableTaps = false;
      taps = {
        "homebrew/homebrew-core" = homebrew-core;
        "homebrew/homebrew-cask" = homebrew-cask;
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
      masApps = {
        "xcode" = 497799835;
      };
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
