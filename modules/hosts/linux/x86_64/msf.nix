# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: msf.nix
# Path: ./modules/hosts/linux/x86_64/msf.nix
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
  flake.nixosConfigurations.msf = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "msf";
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
          "apps"
        ];
        nixosModules = [
          "base-machine"
          "keyboard"
        ];
        userModules = [
          "media"
        ];
        profileModules = [
          "mediaserver"
        ];
        applicationModules = [
          "tailscale.core"
        ];
      })
      ++ [
        {
          my = {
            hostSecrets.file = "${secrets.outPath}/hosts/msf.yaml";
            keyboard.enable = true;
            base-machine = {
              enable = true;
              bootMode = "uefi";
              rootDevice = "/dev/nvme0u1p2";
            };
            apps = {
              tailscale-core.enable = true;
            };
          };
        }
      ];
  };
}
