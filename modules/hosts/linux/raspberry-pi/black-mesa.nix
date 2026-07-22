# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: black-mesa.nix
# Path: ./modules/hosts/linux/raspberry-pi/black-mesa.nix
# Description: Módulo de configuración para la infraestructura.
# =====================
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

  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake.nixosConfigurations.black-mesa = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "black-mesa";
    };

    modules =
      [
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        nixos-hardware.nixosModules.raspberry-pi-3
      ]
      ++ (mkBundle {
        commonModules = [
          "apps"
          "arch.nixos.rpi"
          "settings"
          "host-secrets"
          "authorized-keys"
          "network"
          "home-manager"
          "userProfiles"
        ];
        nixosModules = [
          "keyboard"
          "base-machine"
          "wifi"
        ];
        rpiModules = [
          "common"
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
            hostSecrets.file = "${secrets.outPath}/hosts/black-mesa.yaml";
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
