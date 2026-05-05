{ inputs, lib, ... }:
{
  flake.usersModules.personal =
    { pkgs, ... }:
    {
      home-manager.user.personal =
        { pkgs, lib, ... }:
        {
          home.username = "admin";
          home.stateVersion = "25.11";

          home.homeDirectory = lib.mkMerge [
            (lib.mkIf pkgs.stdenv.isDarwin "/Users/admin")
            (lib.mkIf pkgs.stdenv.isLinux "/Home/admin")
          ];

          home.packages = with pkgs; [
            htop
            bat
          ];
        };

    };
}
