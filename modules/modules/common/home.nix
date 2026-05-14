{inputs, ...}: {
  flake.commonModules = {
    dotfiles = {
      pkgs,
      lib,
      ...
    }: {
      home.file = lib.mkMerge [
        {
          ".config/tmux".source = "${inputs.dotfiles}/tmux";
        }

        ## darwin exclusive
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          "./config".cource = "${inputs.dotfiles}/";
        })

        ## linux servers
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          ".config/hypr".source = "${inputs.dotfiles}/hypr";
        })
      ];
    };
  };
}
