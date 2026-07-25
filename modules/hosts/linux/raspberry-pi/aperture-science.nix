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
          "tailscale.core"
          "tailscale.gui"
        ];
      })
      ++ [
        {
          my = {
            dotfiles.enable = true;
            hostSecrets.file = "${secrets.outPath}/hosts/aperture-science.yaml";
            keyboard.enable = true;
            base-machine = {
              enable = true;
              bootMode = "rpi";
            };
            apps = {
              tailscale-core.enable = true;
              tailscale-gui.enable = true;
              ghostty.enable = true;
            };
          };
        }
      ];
  };
}
