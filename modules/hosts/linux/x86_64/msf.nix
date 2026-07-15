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
    sops-nix
    home-manager
    secrets
    ;
  inherit
    (self)
    nixosModules
    commonModules
    userModules
    profileModules
    applicationModules
    ;
in {
  flake.nixosConfigurations.msf = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "mfs";
    };

    modules = [
      sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager

      commonModules.arch.nixos.x64
      commonModules.settings
      commonModules.host-secrets
      commonModules.userProfiles
      commonModules.authorizedKeys
      commonModules.network
      commonModules.home-manager

      nixosModules.keyboard
      nixosModules.base-machine

      userModules.media

      profileModules.mediaserver

      applicationModules.tailscale

      {
        my = {
          hostSecrets.file = "${secrets.outPath}/hosts/msf.yaml";
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
