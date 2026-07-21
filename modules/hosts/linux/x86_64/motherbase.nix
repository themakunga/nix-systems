# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: motherbase.nix
# Path: ./modules/hosts/linux/x86_64/motherbase.nix
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
    sops-nix
    secrets
    ;
  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake.nixosConfigurations.motherbase = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "motherbase";
    };

    modules =
      [
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
      ]
      ++ (mkBundle {
        commonModules = [
          "arch.nixos.x64"
          "authorized-keys"
          "home-manager"
          "host-secrets"
          "network"
          "settings"
          "userProfiles"
        ];
        nixosModules = [
          "base-machine"
          "keyboard"
          "primaryUser"
        ];
        userModules = [
          "nicolas-server"
        ];
        profileModules = [
          "nicolas-server"
        ];
        applicationModules = [
          "tailscale"
        ];
      })
      ++ [
        {
          my = {
            hostSecrets.file = "${secrets.outPath}/hosts/motherbase.yaml";
            keyboard.enable = true;
            tailscale = {
              enable = true;
              gui.enable = true;
            };
            base-machine = {
              enable = true;
              bootMode = "uefi";
              rootDevice = "/dev/nvme0u1p2";
            };
          };
        }
      ];
  };
}
