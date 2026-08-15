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
          "sd-image"
        ];
      })
      ++ [
        # 👇 ARREGLO: Convertimos este bloque en una función de módulo de NixOS
        ({
          config,
          pkgs,
          lib,
          ...
        }: {
          networking.hostName = "aperture-bootstrap";

          sops = {
            defaultSopsFile = "${inputs.secrets}/common.yaml";
            validateSopsFiles = false;
            age.keyFile = "/Users/nicolas/.config/sops/age/keys.txt";
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

          system.stateVersion = "26.04";

          sdImage = {
            compressImage = true;
            populateFirmwareCommands = lib.mkForce ''
              echo "=> Inyectando firmware oficial de Raspberry Pi 5..."

              # 1. Dar permisos de escritura a la carpeta por si Nix bloqueó archivos previos
              chmod -R +w firmware/

              # 2. Copiar todo el firmware base forzando sobreescritura (-rf)
              cp -rf ${pkgs.raspberrypifw}/share/raspberrypi/boot/* firmware/

              # 3. Volver a dar permisos (los archivos recién copiados vienen como read-only)
              chmod -R +w firmware/

              # 4. Copiar los Device Trees (DTB) actualizados del kernel
              if [ -d "${config.boot.kernelPackages.kernel}/dtbs/broadcom" ]; then
                cp -rf ${config.boot.kernelPackages.kernel}/dtbs/broadcom/* firmware/
              fi

              # 5. Limpieza para evitar conflictos si existe un kernel viejo
              rm -f firmware/kernel*.img

              echo "✅ Firmware base y DTBs inyectados con éxito."            '';
          };
        })
      ];
  };
}
