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
    sops-nix
    disko
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
        disko.nixosModules.disko
        nixos-hardware.nixosModules.raspberry-pi-5
        sops-nix.nixosModules.sops
      ]
      ++ (mkBundle {
        commonModules = [
          "arch.nixos.rpi"
          "settings"
          "authorized-keys"
          "network"
        ];
        nixosModules = [
          "wifi"
        ];
        rpiModules = [
          "common"
          "performance"
          "hardware-rpi5"
          "sd-image"
        ];
        # userModules = [];
        # profileModules = [];
        # applicationModules = [];
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
