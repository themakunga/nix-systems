{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    home-manager
    sops-nix
    nixos-hardware
    disko
    secrets
    ;
  inherit
    (self)
    nixosModules
    rpiModules
    commonModules
    userModules
    profileModules
    applicationModules
    ;
in {
  flake.nixosConfigurations.black-mesa = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "black-mesa";
    };

    modules = [
      commonModules.arch.nixos.rpi
      commonModules.settings
      sops-nix.nixosModules.sops
      commonModules.host-secrets
      commonModules.userProfiles
      commonModules.authorizedKeys
      commonModules.network
      nixosModules.keyboard

      nixos-hardware.nixosModules.raspberry-pi-3
      disko.nixosModules.disko
      rpiModules.disko.black-mesa
      rpiModules.boot-loader
      rpiModules.systemPackages
      rpiModules.config

      home-manager.nixosModules.home-manager
      commonModules.home-manager

      userModules.nicolas-pihole
      profileModules.pihole
      nixosModules.base-machine
      nixosModules.wifi

      applicationModules.tailscale
      applicationModules.pihole
      applicationModules.tofu-dns
      applicationModules.kvm

      {
        zramSwap = {
          enable = true;
          memoryPercent = 100;
        };
      }

      {
        my = {
          hostSecrets.file = "${secrets.outPath}/hosts/black-mesa.yaml";

          tailscale = {
            enable = true;
            gui.enable = false;
          };

          pihole.enable = true;
          tofu-dns.enable = true;

          base-machine = {
            enable = true;
            bootMode = "rpi";
          };
          kvm = {
            enable = true;
            device = "/dev/video0";
            port = 8081;
            resolution = "1920x1080";
          };
        };

        fileSystems."/".device = nixpkgs.lib.mkForce "/dev/disk/by-partlabel/disk-main-root";
      }
    ];
  };
}
