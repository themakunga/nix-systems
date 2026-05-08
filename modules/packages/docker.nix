{...}: let
in {
  flake.nixosModules.docker = {pkgs}: {
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
    ];
  };
}
