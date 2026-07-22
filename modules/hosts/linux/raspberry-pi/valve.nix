# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: valve.nix
# Path: ./modules/hosts/linux/raspberry-pi/valve.nix
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
    nixos-hardware
    ;
  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake.nixosConfigurations.valve = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "valve";
    };

    modules =
      [
        nixos-hardware.nixosModules.raspberry-pi-5
      ]
      ++ (mkBundle {
        commonModules = [
          "arch.nixos.rpi"
          "settings"
          "authorized-keys"
          "network"
        ];
        nixosModules = [
        ];
        rpiModules = [
          "common"
          "hardware-rpi5"
          "sd-image"
        ];
      })
      ++ [
        ({lib, ...}: {
          networking.hostName = "valve";

          services.openssh.settings.PermitRootLogin = "yes";

          my.authorizedKeys = {
            enable = true;
            assignTo = ["root"];
          };

          systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
        })
      ];
  };
}
