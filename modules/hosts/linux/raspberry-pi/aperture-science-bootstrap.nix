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
        inputs.sops-nix.nixosModules.sops # <--- 1. Agregamos el motor de SOPS
      ]
      ++ (mkBundle {
        commonModules = [
          "arch.nixos.rpi"
          "authorized-keys"
          "network"
        ];
        nixosModules = [
          "wifi" # <--- 2. Vuelve tu módulo de WiFi con SOPS
        ];
        rpiModules = [
          "common"
          "hardware-rpi5"
          "sd-image"
        ];
      })
      ++ [
        {
          networking.hostName = "aperture-bootstrap";

          sops = {
            defaultSopsFile = "${inputs.secrets}/common.yaml";
            validateSopsFiles = false;
            age.keyFile = "/var/lib/sops.txt";
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
            ];
          };

          system.stateVersion = "26.04";
        }
      ];
  };
}
