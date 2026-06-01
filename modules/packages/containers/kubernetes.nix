{
  flake.darwinModules.container-kubernetes = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      k9s
      kubectx
      kubectl
    ];
  };
}
