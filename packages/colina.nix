{config, pkgs, lib}:
with lib;
{
  imports = [
    ./docker.nix
  ];

  environment.systemPackages =  with pkgs; [
    docker-client
    colina
  ];

  lanuchd.daemons.docker-socket = mkIf pkgs.stdenv.isDarwin {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c "
        "/bin/wait4path /run/docker.sock && /bin/chmod a+rw /run/docker.sock"
      ];
      RunAtLoad = true;
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
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/colima.err";
      StandardOutPath = "/tmp/colima.out";
    };
  };

   environment.shellInit = ''
    export DOCKER_HOST="unix:///Users/${config.users.primaryUser.username}/.colima/default/docker.sock"
  '';
}
