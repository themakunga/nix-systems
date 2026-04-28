{ ... }:
{
  imports = [
    ../../modules/hosts/darwin.nix
  ];

  homebrew = {
    brews = [

    ];

    casks = [

    ];

    masApps = { };
  };

  system.default.dock.persistent-apps = [
    "/Applications/Nix Apps/Zed.app"
    "/Applications/Nix Apps/WezTerm.app"
    "/Applications/Nix Apps/iTerm2.app"
    "/Applications/Google Chrome.app"
    "/Applications/Firefox.app"
    "/Applications/zoom.us.app/"
  ];
}
