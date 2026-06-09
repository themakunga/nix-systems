{
  flake.commonModules.core.editor =
    { pkgs, ... }:
    {
      environment.systemModules = with pkgs; [
        obsidia
        nvim

        unstable.neovim
        unstable.tree-sitter
      ];
    };
}
