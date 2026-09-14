# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# NixOS host: valve — Raspberry Pi 5 general-purpose server.
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
        applicationModules = ["bat" "yazi" "zoxide"];
        profileModules = ["terminal-tools"];
        commonModules = [
          "apps"
          "dotfiles"
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
          "sd-image-rpi5"
        ];
      })
      ++ [
        ({lib, ...}: {
          networking.hostName = "valve";

          services.openssh.settings.PermitRootLogin = "yes";

          my = {
            dotfiles = {
              user = "root";
              home = "/root";
            };
            authorizedKeys = {
              enable = true;
              assignTo = ["root"];
            };
          };

          systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
        })
      ];
  };
}
