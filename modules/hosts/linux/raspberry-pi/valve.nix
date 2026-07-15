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
  inherit
    (self)
    rpiModules
    commonModules
    nixosModules
    ;
in {
  flake.nixosConfigurations.valve = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "valve";
    };

    modules = [
      commonModules.arch.nixos.rpi
      commonModules.settings

      disko.nixosModules.disko
      nixos-hardware.nixosModules.raspberry-pi-5
      sops-nix.nixosModules.sops
      rpiModules.common
      rpiModules.performance
      rpiModules.hardware-rpi5
      rpiModules.disko-sd
      nixosModules.wifi

      commonModules.network
      commonModules.authorizedKeys

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
