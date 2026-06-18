{
  flake.applicationModules.containers = {
    docker-base = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        docker
        docker-compose
        docker-credential-helpers
      ];
    };
    colima = {
      config,
      pkgs,
      lib,
      ...
    }: let
      inherit (lib) mkIf;
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
      inherit (config.users.primaryUser) username;
    in
      mkIf isDarwin {
        environment = {
          systemPackages = with pkgs; [
            docker-client
            colima
          ];
          shellInit = ''
            export DOCKER_HOST=unix://User/${username}/.colima/default/docker.sock
          '';
        };

        launchd.daemon.docker-socket = {
          serviceConfig = {
            ProgramArgs = [
              "/bin/sh"
              "-c"
              "/bin/wait4path /run/docker.out && /run/docker.sock"
            ];
            RunAtLogin = true;
            StandardErrorPath = "/tmp/docker-socket.err";
            StandardOutPath = "/tmp/docker-socket.out";
          };
        };

        launch.user.agent.colima = {
          serviceConfig = {
            ProgramArguments = [
              "${pkgs.colima}/bin/colima"
              "start"
              "--vm-type=qemu"
              "--mount-type=9p"
              "--cpu=4"
              "--memory=8"
            ];
            RunAtLogin = true;
            KeepAlive = true;
            StandardErrorPath = "/tmp/colima.err";
            StandardOutPath = "/tmp/colima.out";
          };
        };
      };
    rancher = {
      lib,
      pkgs,
      ...
    }: let
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
      inherit (lib) mkIf;
    in
      mkIf isDarwin {
        environment.systemPackages = with pkgs; [
          rancher
        ];

        homebrew.casks = ["rancher"];
      };
    kubernetes = {
      lib,
      pkgs,
      ...
    }: let
      inherit (lib) mkIf mkMerge;
      inherit (pkgs.stdenv.hostPlatform) isDarwin;
    in
      mkMerge [
        {
          environment = {
            systemPackages = with pkgs; [
              kubectl
              kubernetes-helm
              kubectx
              k9s
              kustomize
            ];
            interactiveShellInit = ''
              alias k="kubectl"
              alias kx="kubectx"
              alias kn="kubens"
            '';
          };
        }

        (mkIf isDarwin {
          homebrew.casks = ["openlens"];
        })
      ];
  };
}
