{
  flake.commonModules.dev.core =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        libpq
        postgresql
        dbeaver-bin
      ];
    };
}
