{
  flake.usersModules.nicolas-42devs = {
    home-manager.users.nicolas-42devs = {
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
        userName = "Nicolas Villarroel";
        userEmail = "nicolasz@42devs.cl";
      };
    };
  };
}
