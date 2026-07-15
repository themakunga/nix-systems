# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
# === DOCUMENTATION ===
# File: dummy.nix
# Path: ./modules/hosts/lsp/dummy.nix
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
    nix-darwin
    ;
  inherit
    (self)
    commonModules
    darwinModules
    nixosModules
    userModules
    ;
in {
  flake = {
    nixosConfigurations.lsp-dummy = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit self inputs;
        hostName = "lsp-dummy-nixos";
      };

      modules = [
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager

        commonModules.host-secrets
        commonModules.settings
        commonModules.arch.nixos.x64
        commonModules.userProfiles
        commonModules.authorizedKeys
        commonModules.network
        commonModules.home-manager

        nixosModules.base-machine

        userModules.nicolas-admin

        {
          my.base-machine = {
            enable = true;
            bootMode = "uefi";
          };
          fileSystems."/".device = "/dev/null";
          boot.loader.grub.device = ["/dev/null"];
        }
      ];
    };
    darwinConfigurations.lsp-dummy = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit self inputs;
        hostName = "lsp-dummy-darwin";
      };

      modules = [
        sops-nix.darwinModules.sops
        home-manager.darwinModules.home-manager

        commonModules.host-secrets
        commonModules.arch.darwin.silicon
        commonModules.settings
        commonModules.userProfiles
        commonModules.home-manager

        darwinModules.extras
        darwinModules.security
        darwinModules.dock
        darwinModules.finder

        userModules.nicolas-personal

        {
          system.primaryUser = "nicolas";
        }
      ];
    };
  };
}
