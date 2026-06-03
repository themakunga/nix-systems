{
  self,
  lib,
  ...
}: let
  inherit (lib) mkMerge mkIf optionals;
in {
  flake = {
    commonModules.personal = {pkgs, ...}: let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
    in {
      users.users.nicolas = mkMerge [
        {
          description = "Nicolas Villarrioel M";
        }
        (mkIf (!isDarwin) {
          extraGroups = [
            "wheel"
            "networkmanager"
            "docker"
          ];
          isNormalUser = true;
        })
      ];
    };
    darwinModules.personal = {
      imports = [
        self.darwinModules.homebrew-config
      ];

      homebrew = {
        casks = [];
        masApps = {
          "Termius" = 1176074088;
          "Whatsapp Messenger" = 310633997;
        };
      };
    };

    homeManagerModules.personal = {pkgs, ...}: let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
    in {
      imports = [
        self.homeManagerModules.common
      ];

      home = {
        username = "nicolas";
        packages = with pkgs;
          [
            halloy
            irssi
            nchat
          ]
          ++ optionals (!isDarwin) [
            firefox
            firefox-devedition-bin
          ];
      };

      programs.git = {
        userName = "Nicolas Villarroel Martines (TheMakunga)";
        userEmail = "nmartinezv@icloud.com";
      };
    };
  };
}
