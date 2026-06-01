{
  flake.commonModules.container-core = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
      docker-credential-helpers
    ];
  };
}
