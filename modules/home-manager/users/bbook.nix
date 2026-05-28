{
  flake.usersModules.nicolas-bbook = {
    home-manager.users.nicolas-bbook = {
      pkgs,
      lib,
      ...
    }: {
      home = {
        username = "nicolas";
        stateVersion = "25.11";

        homeDirectory = lib.mkMerge [
          (lib.mkIf pkgs.stdenv.isDarwin "/Users/nicolas")
          (lib.mkIf pkgs.stdenv.isLinux "/home/nicolas")
        ];

        programs = with pkgs; [
        ];
      };

      programs.git = {
        enable = true;
        userName = "Nicolas Martinez Villarroel";
        userEmail = "nmartinezv@icloud.com";
      };
    };
  };
}
