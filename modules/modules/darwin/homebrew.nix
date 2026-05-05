{self, inputs,lib, config, ...}: {
  flake.darwinModules.homebrew-config = {
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    ...
    }: lib.mkForce {
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
          "mas" # enble apps store
          # browsers
          "google-chome"
          "firefox"
          "firefox-dev"
          # markdown editor
          "typora"
          # social networks
          "slack"
          "discord"
          "mattermost"
        ];
        cask = [
          # markdown parsers
          "pandoc"
        ];
        masApp = {
          "xcode" = 497799835;
        };
      };
    };
}
