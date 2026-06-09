{
  self,
  lib,
  ...
}:
let
  inherit (lib) mkIf optionals;
  inherit (self)
    nixosModules
    homeManagerModules
    commonModules
    ;
in
{
  flake.profileModules.cave-johnson =
    { pkgs, ... }:
    {
      imports = [ ];

      users.user.nicolas = {
        isNomalUser = true;
        description = "Main Administrator";
        extraGroups = [
          "wheel"
          "networkmanager"
          "docker"
        ];
      };

      home-manager.users.nicolas = {
        imports = [
          homeManagerModules
        ];

        home = {
          username = "nicolas";
          packages = with pkgs; [
            tmux
            nano
            curl
          ];
        };

        programs = {
          bash.enable = true;
        };
      };
    };
}
