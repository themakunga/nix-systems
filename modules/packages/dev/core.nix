{
  flake.commonModules.dev.core =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        git
        pre-commit
        gitflow
        lazygit
        lazyactions
      ];
    };
}
