# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# NixOS host: black-mesa — Raspberry Pi Zero 2W running Pi-hole and KVM.
{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    sops-nix
    disko
    secrets
    ;

  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake.nixosConfigurations.black-mesa = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "black-mesa";
    };

    modules =
      [
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
      ]
      ++ (mkBundle {
        commonModules = [
          "dotfiles"
          "apps"
          "arch.nixos.rpi"
          "settings"
          "host-secrets"
          "authorized-keys"
          "network"
          "userProfiles"
          "git-identity"
          "sops-gpg"
        ];
        nixosModules = [
          "keyboard"
          "base-machine"
          "static-ip"
          "wifi"
        ];
        rpiModules = [
          "common"
          "hardware-rpi-zero2w"
          "performance"
          "sd-image"
        ];
        userModules = [
          "nicolas-pihole"
        ];
        profileModules = [
          "pihole"
        ];
        applicationModules = [
          "pihole"
          "tailscale.core"
          "tofu-dns"
          "kvm"
        ];
      })
      ++ [
        {
          zramSwap = {
            enable = true;
            memoryPercent = 100;
          };
        }

        {
          my = {
            dotfiles.enable = true;
            hostSecrets.file = "${secrets.outPath}/hosts/black-mesa.yaml";

            # IP estática — RPi 192.168.1.2x
            # RPi Zero 2W no tiene Ethernet — usa wlan0 (WiFi)
            # Verificar: ip link show
            network.staticIP = {
              enable = true;
              address = "192.168.1.21";
              gateway = "192.168.1.1";
              interface = "wlan0";
            };

            pihole.enable = true;
            tofu-dns.enable = true;
            apps.tailscale-core.enable = true;
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
        }
      ];
  };
}
