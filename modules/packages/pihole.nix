{
  flake.nixosModules.pihole = {config, ...}: {
    sops.secrets."pihole/auth_file" = {};

    virtualization.oci-containers = {
      backend = "podman";
      containers.pihole = {
        image = "pihole/pihole:latest";
        autoStart = true;
        ports = [
          "53:53/tcp"
          "53:53/udp"
          "80:80/tcp"
        ];
        environmentFiles = [
          config.sops.secrets."pihole/env_file".path
        ];
        environment = {
          TZ = "America/Santiago";
        };

        volumes = [
          "/var/lib/pihole/etc-pihole:/etc/pihole"
          "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
        ];
        extraOptions = ["--cap-add=NET_ADMIN"];
      };
    };
    networking.firewall = {
      allowedTCPPorts = [
        53
        80
      ];
      allowedUDPPorts = [
        53
      ];
    };
  };
}
