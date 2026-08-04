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
