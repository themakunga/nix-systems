{ inputs, ... }:
{
  flake.usersModules.nicolas-bbook =
    {
      pkgs,
      ...
    }:
    {
      home-manager.users.nicolas-bbook =
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
            userName = "Nicolas Martinez Villarroel";
            userEmail = "nmartinezv@icloud.com";
          };
        };
    };
}
