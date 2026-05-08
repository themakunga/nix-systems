{lib, ...}: {
  flake.usersModules.personal = {...}: {
    home-manager.user.personal = {pkgs, ...}: {
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
