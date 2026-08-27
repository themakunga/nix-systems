# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: steamdeck.nix
# Path: ./modules/hosts/linux/x86_64/steamdeck.nix
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
    sops-nix
    secrets
    ;
  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake.nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "steamdeck";
    };

    modules =
      [
        sops-nix.nixosModules.sops
      ]
      ++ (mkBundle {
        commonModules = [
          "dotfiles"
          "arch.nixos.x64"
          "apps"
          "authorized-keys"
          "host-secrets"
          "network"
          "settings"
          "userProfiles"
          "git-identity"
          "sops-gpg"
        ];
        nixosModules = [
          "base-machine"
          "keyboard"
          "static-ip"
        ];
        userModules = [
          "deck"
        ];
        profileModules = [
          "steamdeck"
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
            hostSecrets.file = "${secrets.outPath}/hosts/steamdeck.yaml";
            keyboard.enable = true;

            # IP estática — x86 192.168.1.3x
            # SteamDeck: verificar con ip link show (WiFi: wlan0, USB-C Ethernet: enp4s0)
            network.staticIP = {
              enable = true;
              address = "192.168.1.32";
              gateway = "192.168.1.1";
              interface = "enp4s0";
            };

            base-machine = {
              enable = true;
              bootMode = "uefi";
              rootDevice = "/dev/nvme0u1p2";
            };
            apps = {
              tailscale-core.enable = true;
              tailscale-gui.enable = true;
            };
          };
        }
      ];
  };
}
