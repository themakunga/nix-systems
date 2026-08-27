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
      ]
      ++ (mkBundle {
        commonModules = [
          "dotfiles"
          "arch.nixos.x64"
          "authorized-keys"
          "host-secrets"
          "network"
          "settings"
          "userProfiles"
          "apps"
          "git-identity"
          "sops-gpg"
        ];
        nixosModules = [
          "base-machine"
          "keyboard"
          "static-ip"
        ];
        userModules = [
          "nicolas-server"
        ];
        profileModules = [
          "nicolas-server"
        ];
        applicationModules = [
          "tailscale.core"
          "podman"
          "container-stack"
          "samba-share"
          "traefik"
          "cloudflare-tunnel"
        ];
      })
      ++ [
        {
          my = {
            dotfiles.enable = true;
            hostSecrets.file = "${secrets.outPath}/hosts/motherbase.yaml";
            keyboard.enable = true;

            # IP estática — x86 192.168.1.3x
            # Verificar interfaz: ip link show (común: enp3s0, eno1, enp4s0)
            network.staticIP = {
              enable = true;
              address = "192.168.1.30";
              gateway = "192.168.1.1";
              interface = "enp3s0";
            };

            base-machine = {
              enable = true;
              bootMode = "uefi";
              rootDevice = "/dev/nvme0u1p2";
            };
            apps = {
              tailscale-core.enable = true;
              cloudflare-tunnel.enable = true;
              podman.enable = true;
              container-stack.enable = true;
              traefik.enable = true;
              samba-share.enable = true; # <--- AÑADIDO AQUÍ
            };
            services = {
              container-stack.portainer.enable = true;
              samba-share = {
                user = "admin";
              };
              traefik = {
                acmeEmail = "tu_correo@ejemplo.com";
                useCloudflare = true;
              };
            };
          };
        }
      ];
  };
}
