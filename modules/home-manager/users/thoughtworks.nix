{self, ...}: {
  flake.homeMangerModules.nicolas = {
    config,
    lib,
    pkgs,
    ...
  }: let
    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  in {
    imports = [
      self.homeManagerModules.common
      self.darwinModules.homebrew-config
    ];

    homebrew = {
      casks = [
        "google-chrome"
        "chromium"
        "dbeaver"
        "iTerm"
      ];
      masApps = {
      };
    };

    home = {
      username = "nicolas";

      packages = with pkgs;
        [
        ]
        ++ lib.optionals (!isDarwin) [
        ];
    };

    programs = {
      git = {
        userName = "Nicolas Villarroel M.";
        userEmail = "nicolas.villarroel@thoughtworks.com";
      };
    };
  };
}
