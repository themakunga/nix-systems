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
    home-manager
    sops-nix
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
  flake.nixosConfigurations.steamdeck = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit self inputs;
      hostName = "steamdeck";
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

      userModules.deck

      profileModules.steamdeck

      applicationModules.tailscale
      {
        my = {
          hostSecrets.file = "${secrets.outPath}/hosts/steamdeck.yaml";
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
