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

  mkBundle = self.lib.mkBundle inputs.nixpkgs.lib self;
in {
  flake = {
    nixosConfigurations.lsp-dummy = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit self inputs;
        hostName = "lsp-dummy-nixos";
      };

      modules =
        [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
        ]
        ++ (mkBundle {
          commonModules = [
            "arch.nixos.x64"
            "settings"
            "host-secrets"
            "userProfiles"
            "authorized-keys"
            "network"
            "home-manager"
          ];
          nixosModules = [
            "base-machine"
          ];
          userModules = [
            "nicolas-admin"
          ];
        })
        ++ [
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

      modules =
        [
          sops-nix.darwinModules.sops
          home-manager.darwinModules.home-manager
        ]
        ++ (mkBundle {
          commonModules = [
            "arch.darwin.silicon"
            "settings"
            "host-secrets"
            "userProfiles"
            "home-manager"
          ];
          darwinModules = [
            "primaryUser"
            "extras"
            "security"
            "finder"
          ];
          userModules = [
            "nicolas-personal"
          ];
        })
        ++ [
          {
            my.primaryUser = {
              enable = true;
              username = "nicolas";
            };
          }
        ];
    };
  };
}
