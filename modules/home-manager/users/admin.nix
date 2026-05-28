{
  flake.usersModules.admin-user = {
    home-manager.user.admin-user = {
      pkgs,
      lib,
      ...
    }: {
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
