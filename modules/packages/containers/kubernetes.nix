{
  flake.darwinModules.container.kuberneteskubernetes = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      k9s
      kubectx
      kubectl
    ];
  };
}
