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
  inherit
    (self)
    nixosModules
    rpiModules
    commonModules
    userModules
    profileModules
    applicationModules
    ;
in {
  flake.nixosConfigurations.aperture-science = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "aperture-science";
    };

    modules = [
      commonModules.arch.nixos.rpi
      commonModules.settings
      sops-nix.nixosModules.sops
      commonModules.host-secrets

      commonModules.userProfiles
      commonModules.authorizedKeys
      commonModules.network
      nixosModules.keyboard
      nixosModules.wifi

      nixos-hardware.nixosModules.raspberry-pi-5
      disko.nixosModules.disko

      home-manager.nixosModules.home-manager
      commonModules.home-manager

      rpiModules.common
      rpiModules.hardware-rpi5
      rpiModules.performance
      rpiModules.disko-nvme

      userModules.nicolas-admin
      userModules.glados
      profileModules.nicolas-admin
      profileModules.glados

      applicationModules.tailscale
      nixosModules.base-machine
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
