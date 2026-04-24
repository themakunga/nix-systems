{pkgs}: {
  imports = [
    ./docker.nix
  ];

  environment.systemPackages = with pkgs; [
    docker-credential-helpers
    kubectx
  ];
}
