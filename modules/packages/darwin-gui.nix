{ inputs, ... }:
{
  flake = {
    darwinGuiModules = {
      browsers = {
        homebrew.casks = [
          "google-chrome"
          "firefox"
        ];
      };
      documents = {
        homebrew = {
          casks = [
            "typora"
          ];
          brew = [
            "pandoc"
          ];
        };
      };
      community = {
        homebrew.casks = [
          "slack"
          "discord"
          "mattermost"
        ];
      };
    };
  };
}
