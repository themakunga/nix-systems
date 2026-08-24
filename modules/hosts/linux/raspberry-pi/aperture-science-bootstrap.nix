# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Host: aperture-bootstrap (Imagen SD efímera para instalación)
# =========================================================
{
  self,
  inputs,
  ...
}: let
  inherit (inputs) nixpkgs nixos-hardware;
  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake.nixosConfigurations.aperture-bootstrap = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "aperture-bootstrap";
    };

    modules =
      [
        nixos-hardware.nixosModules.raspberry-pi-5
        inputs.sops-nix.nixosModules.sops
      ]
      ++ (mkBundle {
        commonModules = [
          "arch.nixos.rpi"
          "authorized-keys"
          "network"
        ];
        nixosModules = [
          "wifi"
        ];
        rpiModules = [
          "common"
          "hardware-rpi5"
          "sd-image-rpi5"
        ];
      })
      ++ [
        (_: {
          networking.hostName = "aperture-bootstrap";

          sops = {
            defaultSopsFile = "${inputs.secrets}/common.yaml";
            validateSopsFiles = false;
            age.keyFile = "/etc/age/keys.txt";
          };

          services.openssh = {
            enable = true;
            settings.PermitRootLogin = "yes";
          };

          my.authorizedKeys = {
            enable = true;
            assignTo = ["root"];
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfrS5Ps9OxiIKgMJo718RbJ7Lwaijwt3g0lEBb8mhCt nicolas@Nicolass-MacBook-Pro.local"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvc7ExxEKPdvwtfa701VyQbrZWUGPCmvFjSAGoqRc7V nmartinezv@icloud.com"
            ];
          };

          system.stateVersion = "26.05";
        })
      ];
  };
}
