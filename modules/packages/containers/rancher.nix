{
  flake.darwinModules.container.rancher = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      rancher
    ];
  };
}
