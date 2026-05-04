{ inputs, lib, ... }:
{
  flake.usersModules.admin-user =
    { pkgs, ... }:
    {
      home-manager.user.admin-user =
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
