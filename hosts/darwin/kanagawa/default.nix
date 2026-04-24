{pkgs, ...}:{
  imports = [
    ../../modules/hosts/darwin.nix
  ];

  environment = {
    systemPackages = with pkgs; [

    ];

    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  homebrew = {
    brews = [
      "nixfmt"
    ];
    casks = [
      "typora"
      "firefox"
      "google-chome"
      "obsidian"
      "discord"

    ];
    masApps = {

    };
  };

  system.defaults.dock.persistent-apps = [
    "/Applications/Nix Apps/Zed.app"
          "/Applications/Nix Apps/WezTerm.app"
          "/Applications/Nix Apps/iTerm2.app"
          "/Applications/Google Chrome.app"
          "/Applications/Firefox.app"
          "/Applications/zoom.us.app/"
  ];
}
