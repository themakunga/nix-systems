{self, ...}: {
  flake.homeManagerModules."42devs" =
    # {
    # lib,
    # pkgs,
    # ...
    # }:
    # let
    #   inherit (pkgs.stdenv.hostPlatform) isDarwin;
    # in
    {
      imports = [
        self.homeManagerModules.common
        self.darwinModules.homebrew-config
      ];

      homebrew = {
        casks = [
        ];
        masApps = {
        };
      };

      home = {
        username = "nicolas";
      };

      programs = {
        git = {
          userName = "Nicolas Villarroel M.";
          userEmail = "nicolas@42devs.cl";
        };
      };
    };
}
