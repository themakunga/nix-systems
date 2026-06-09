{
  flake = {
    darwinModules.container.colimacolima =
      {
        config,
        pkgs,
        nixosModules,
      }:
      {
        modules = [
          nixosModules.docker
        ];
        environment.systemPackaces = with pkgs; [
          docker-client
          colima
        ];

        lanuchd.daemon.docker-socket = {
          serviceConfig = {
            ProgramArguments = [
              "/bin/sh"
              "-c "
              "/bin/wait4path /run/docker.out && /run/docker.sock"
            ];
            RunAtLogin = true;
            StandardErrorPath = "/tmp/docker-sock.err";
            StandardOutPath = "/tmp/docker-socke.out";
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

        environment.shellInit = ''
          export DOCKER_HOST="unix://Users/${config.users.primaryUser.username}/.colima/default/docker.sock"
        '';
      };
  };
}
