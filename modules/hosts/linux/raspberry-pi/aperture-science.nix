# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Host: aperture-science (RPi 5 AI Node)
# =========================================================
{
  self,
  inputs,
  lib,
  ...
}: let
  inherit
    (inputs)
    nixpkgs
    disko
    sops-nix
    nixos-hardware
    ;
  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake.nixosConfigurations.aperture-science = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "aperture-science";
    };

    modules =
      [
        nixos-hardware.nixosModules.raspberry-pi-5
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
      ]
      ++ (mkBundle {
        commonModules = [
          "dotfiles"
          "apps"
          "arch.nixos.rpi"
          "authorized-keys"
          "host-secrets"
          "network"
          "settings"
          "userProfiles"
        ];
        nixosModules = [
          "base-machine"
          "nix-anywhere" # Fundamental para inyectar llaves SSH durante el despliegue
          "wifi"
        ];
        rpiModules = [
          "common"
          "disko-nvme" # Utiliza tu módulo que formatea automáticamente /dev/nvme0n1
          "hardware-rpi5"
          "performance"
        ];
        userModules = [
          "glados" # Importa el módulo y la jaula de GLaDOS
        ];
        applicationModules = [
          "tailscale.core"
          "agents"
        ];
      })
      ++ [
        {
          # Declaramos primaryUser localmente para satisfacer al módulo nix-anywhere
          options.my.primaryUser.username = lib.mkOption {
            type = lib.types.str;
            default = "admin";
          };

          config.my = {
            # Establece al usuario "admin" como el objetivo para inyectar tus llaves SSH
            primaryUser.username = "admin";

            nix-anywhere.enable = true;

            # Si ya configuraste sops para este host, descomenta la siguiente línea:
            # hostSecrets.file = "${secrets.outPath}/hosts/aperture-science.yaml";

            base-machine = {
              enable = true;
              bootMode = "rpi";
            };

            apps = {
              tailscale-core.enable = true;
            };

            agents = {
              ollama = {
                enable = true;
                cores = 4;
                memory = "6G"; # Asignamos 6GB al LLM, reservando 2GB para el OS
              };
              zeroclaw = {
                enable = true;
                cores = 2;
                memory = "1G";
              };
            };

            # Creamos al usuario Administrador al vuelo
            userProfiles.admin = {
              username = "admin";
              fullName = "Aperture Admin";
              description = "System Administrator";
              isSystem = false;
              isAdmin = true; # Otorga permisos de sudo/wheel
              isNetworkManager = true;
              extraGroups = ["docker"];
            };
          };
        }
      ];
  };
}
