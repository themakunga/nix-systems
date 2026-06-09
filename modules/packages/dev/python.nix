{
  flake.commonModules.dev.python =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        python312
        pipx
        uv
        ruff
        pyright
        debugpy
      ];
    };
}
