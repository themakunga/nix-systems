{ inputs, ... }:
{
  flake.usersModules.nicolas-42devs =
    {
      pkgs,
      ...
    }:
    {
      home-manager.users.nicolas-42devs =
        { pkgs, lib, ... }:
        {
          home.username = "nicolas";
          home.stateVersion = "25.11";

          home.homeDirectory = lib.mkMerge [
            (lib.mkIf pkgs.stdenv.isDarwin "/Users/nicolas")
            (lib.mkIf pkgs.stdenv.isLinux "/home/nicolas")
          ];

          home.programs = with pkgs; [

          ];

          programs.git = {
            enable = true;
            userName = "Nicolas Villarroel";
            userEmail = "nicolasz@42devs.cl";
          };
        };
    };
}
