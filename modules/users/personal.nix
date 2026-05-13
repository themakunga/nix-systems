{lib, ...}: {
  flake.usersModules.personal = {
    home-manager.user.personal = {pkgs, ...}: {
      home = {
        username = "admin";
        stateVersion = "25.11";

        homeDirectory = lib.mkMerge [
          (lib.mkIf pkgs.stdenv.isDarwin "/Users/admin")
          (lib.mkIf pkgs.stdenv.isLinux "/Home/admin")
        ];

        packages = with pkgs; [
          htop
          bat
        ];
      };
    };
  };
}
