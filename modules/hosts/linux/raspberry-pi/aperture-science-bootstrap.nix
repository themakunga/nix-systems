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
  config,
  lib,
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

          sdImage.populateFirmwareCommands = lib.mkAfter ''
            echo "=> Solucionando compatibilidad de Raspberry Pi 5 (Inyectando DTB)..."

            # Copiar todos los Device Trees de Broadcom generados por el kernel
            if [ -d "${config.boot.kernelPackages.kernel}/dtbs/broadcom" ]; then
              cp -rf ${config.boot.kernelPackages.kernel}/dtbs/broadcom/* firmware/
            fi

            # Verificación de seguridad
            if [ -f "firmware/bcm2712-rpi-5-b.dtb" ]; then
              echo "✅ DTB de RPi 5 inyectado correctamente en la partición boot."
            else
              echo "⚠️ Advertencia: No se encontró el DTB para RPi 5 en el kernel."
            fi
          '';
        }
      ];
  };
}
