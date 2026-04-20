{ config, ... }:
{
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

    casks = [ ];

    masApps = {
      "Xcode" = 497799835;
    };
  };
}
