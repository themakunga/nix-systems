{self, ...}: {
  flake.homeManagerModules.bbook = {
    # lib,
    # pkgs,
    # ...
    # }:
    # let
    # inherit (pkgs.stdenv.hostPlatform) isDarwin;
    # in
    # {
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
        userEmail = "nmartinez@bbook.cl";
      };
    };
  };
}
