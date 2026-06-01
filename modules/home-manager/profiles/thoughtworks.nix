{
  self,
  lib,
  ...
}: {
  flake = {
    commonModules.thougthworks = {pkgs, ...}: let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
    in {
      users.users.nicolas = {
        description = "Nicolas Villarroel M.";
        extraGroups = lib.mkIf (!isDarwin) [
          "wheel"
          "networkmanager"
          "docker"
        ];
        isNormalUser = lib.mkIf (!isDarwin) true;
      };
    };
    darwinModules.thoughtworks = {
      imports = [
        self.darwinModules.homebrew-config
      ];

      homebrew = {
        casks = [
          "google-chrome"
          "chromium"
          "dbeaver"
          "iTerm2"
        ];
        masApps = {};
      };
    };
    homeManagerModules.thougthworks = {
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
      ];

      home = {
        username = "nicolas";
      };

      programs = {
        git = {
          userName = "Nicolas Villarroel M.";
          userEmail = "nicolas.villarroel@thoughtworks.com";
        };
      };
    };
  };
}
