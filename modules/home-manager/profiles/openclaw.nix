{self, ...}: {
  flake.homeManagerModules.openclaw = {
    #   lib,
    #   pkgs,
    #   ...
    # }:
    # let
    #   inherit (pkgs.stdenv.hostPlatform) isDarwin;
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
        userName = "OpenClaw Agent";
        userEmail = "opeclaw@yorkitos.com";
      };
    };
  };
}
