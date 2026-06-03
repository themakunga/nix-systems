{ self, lib, ... }:
let
  inherit (lib) mkIf;
  inherit (self) darwinModules homeManagerModules commonModules;
{
  flake.profileModules.grainger =
    { pkgs, ... }:
    {
      imports = [
        darwinModules.containers-rancher
        darwinModules.homebrew-config
      ];

      homebrew = {
        enable = true;
        casks = ["microft-teams"];
        brews = ["vault"];
      };

      home-manager.users.nicolas = { config = hmConfig; ... }: {
      imports = [
        self.homeManagerModules.common
      ];
        home.username = "nicolas";

        programs = {
          git = {};
          sops-gpg = {};
        };

  };


    };
}
