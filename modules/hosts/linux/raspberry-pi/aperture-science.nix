# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: aperture-science.nix
# Path: ./modules/hosts/linux/raspberry-pi/aperture-science.nix
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
    disko
    sops-nix
    nixos-hardware
    secrets
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
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
      ]
      ++ (mkBundle {
        commonModules = [
          "arch.nixos.rpi"
          "authorized-keys"
          "home-manager"
          "host-secrets"
          "network"
          "settings"
          "userModules"
        ];
        nixosModules = [
          "base-machine"
          "keyboard"
          "wifi"
        ];
        rpiModules = [
          "common"
          "disko-nvme"
          "hardware-rpi5"
          "performance"
        ];
        userModules = [
          "nicolas-admin"
          "glados"
        ];
        profileModules = [
          "nicolas-admin"
          "glados"
        ];
        applicationModules = [
          "tailscale"
        ];
      })
      ++ [
        {
          my = {
            hostSecrets.file = "${secrets.outPath}/hosts/aperture-science.yaml";
            keyboard.enable = true;
            tailscale = {
              enable = true;
              gui.enable = true;
            };
            base-machine = {
              enable = true;
              bootMode = "rpi";
            };
          };
        }
      ];
  };
}
